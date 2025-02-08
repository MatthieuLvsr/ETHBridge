// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IWrappedNative} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IWrappedNative.sol";

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";

//solhint-disable interface-starts-with-i
interface CCIPRouter {
  function getWrappedNative() external view returns (address);
}

contract ETHBridge is CCIPReceiver {
    using SafeERC20 for IERC20;

    error InvalidTokenAmounts(uint256 gotAmounts);
    error InvalidToken(address gotToken, address expectedToken);
    error TokenAmountNotEqualToMsgValue(uint256 gotAmount, uint256 msgValue);

    event EthSent(address indexed sender, address indexed receiver, uint256 amount, uint64 destinationChain);
    event ExcessRefunded(address indexed refundReceiver, uint256 excessAmount);

    IWrappedNative public immutable i_weth;

    uint64 private immutable DEST_CHAIN_ID;

    constructor(address router, uint64 _dest_chain) CCIPReceiver(router) {
        i_weth = IWrappedNative(CCIPRouter(router).getWrappedNative());
        i_weth.approve(router, type(uint256).max);
        DEST_CHAIN_ID = _dest_chain;
    }

    receive() external payable {}

    function getFee(
        address _receiver,
        uint256 _amount
    ) public view returns (uint256 fee) {
        Client.EVM2AnyMessage memory message = _buildCCIPMessage(_receiver, _amount);

        return IRouterClient(getRouter()).getFee(DEST_CHAIN_ID, message);
    }

    function send(address _receiver, uint256 _amount) external payable {
        require(_receiver != address(0), "Invalid receiver address");
        require(_amount > 0, "Amount must be greater than zero");
        require(msg.value >= _amount, "Not enough ETH sent");

        uint256 estimatedFee = getFee(_receiver, _amount);
        uint256 totalRequired = _amount + estimatedFee;

        require(msg.value >= totalRequired, "Insufficient ETH for transfer and fees");


        Client.EVM2AnyMessage memory message = _buildCCIPMessage(_receiver, _amount);
        _ccipSend(message, estimatedFee);

        emit EthSent(msg.sender, _receiver, _amount, DEST_CHAIN_ID);

        uint256 excess = msg.value - totalRequired;
        if (excess > 0) {
            (bool refunded, ) = msg.sender.call{value: excess}("");
            require(refunded, "Refund failed");
            emit ExcessRefunded(msg.sender, excess);
        }
    }

    function _buildCCIPMessage(
        address _receiver,
        uint256 _amount
    ) private view returns (Client.EVM2AnyMessage memory) {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: address(i_weth),
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV2({
                    gasLimit: 400_000,
                    allowOutOfOrderExecution: true
                })
            ),
            feeToken: address(0)
        });
        return evm2AnyMessage;
    }

    function _ccipSend(
        Client.EVM2AnyMessage memory message,
        uint256 fees
    ) private returns (bytes32) {

        i_weth.deposit{value: message.tokenAmounts[0].amount}();

        return IRouterClient(getRouter()).ccipSend{value: fees}(DEST_CHAIN_ID, message);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        address receiver = abi.decode(message.data, (address));

        if (message.destTokenAmounts.length != 1) {
            revert InvalidTokenAmounts(message.destTokenAmounts.length);
        }

        if (message.destTokenAmounts[0].token != address(i_weth)) {
            revert InvalidToken(message.destTokenAmounts[0].token, address(i_weth));
        }

        uint256 tokenAmount = message.destTokenAmounts[0].amount;
        i_weth.withdraw(tokenAmount);

        (bool success,) = payable(receiver).call{value: tokenAmount}("");
        if (!success) {
            i_weth.deposit{value: tokenAmount}();
            i_weth.transfer(receiver, tokenAmount);
        }
    }
}
