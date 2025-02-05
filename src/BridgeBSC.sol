// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

contract BridgeBSC {
    IRouterClient public immutable router;
    address public immutable WETH; // WETH contract address on BSC Testnet
    uint64 public constant DESTINATION_CHAIN_ID = 11155111; // Sepolia Chain ID

    event FundsSent(address indexed sender, uint256 amount);
    event FundsReceived(address indexed sender, uint256 amount);

    constructor(address _router, address _weth) {
        router = IRouterClient(_router);
        WETH = _weth;
    }

    /**
     * @notice Sends BNB (converted to WETH) from BSC to Sepolia via CCIP, paying fees in BNB.
     * @param receiver The recipient address on Sepolia.
     */
    function sendBnbToSepolia(address receiver) external payable {
        require(msg.value > 0, "Must send BNB");

        // Convert BNB to WETH
        IWETH(WETH).deposit{value: msg.value}();

        // Approve Router to spend WETH
        IERC20(WETH).approve(address(router), msg.value);

        // Prepare message data
        bytes memory data = abi.encode(receiver, msg.value);

        // Define token amounts for CCIP transfer
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount;
        tokenAmounts[0] = Client.EVMTokenAmount({
            token: WETH,
            amount: msg.value
        });

        // Prepare CCIP message
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: data,
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: address(0) // Pay fees in native token (BNB)
        });

        // Get required fee
        uint256 fees = router.getFee(DESTINATION_CHAIN_ID, message);
        require(msg.value > fees, "Not enough BNB for fees");

        // Send CCIP transaction
        router.ccipSend{value: fees}(DESTINATION_CHAIN_ID, message);

        emit FundsSent(msg.sender, msg.value);
    }

    /**
     * @notice Handles incoming WETH from Sepolia and transfers it to the recipient.
     * @param message The received CCIP message.
     */
    function ccipReceive(Client.Any2EVMMessage memory message) external {
        require(msg.sender == address(router), "Unauthorized sender");

        (address user, uint256 amount) = abi.decode(message.data, (address, uint256));

        // Transfer WETH to the recipient
        IERC20(WETH).transfer(user, amount);

        emit FundsReceived(user, amount);
    }

    /**
     * @notice Allows the contract to receive BNB when withdrawing WETH.
     */
    receive() external payable {}
}
