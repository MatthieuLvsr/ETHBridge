// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "src/ETHBridge.sol";

contract FromSepToBSC is Script {
    address constant ETH_BRIDGE_SEPOLIA = vm.envAddress("ETH_BRIDGE_SEPOLIA");
    
    address constant RECEIVER_BSC = vm.envAddress("RECEIVER_BSC");
    
    // Amount to send in wei (Replace with desired amount)
    uint256 constant AMOUNT = 0.1 ether;

    function run() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);
        
        ETHBridge bridge = ETHBridge(ETH_BRIDGE_SEPOLIA);
        uint256 fee = bridge.getFee(RECEIVER_BSC, AMOUNT);
        uint256 totalAmount = AMOUNT + fee;

        bridge.send{value: totalAmount}(RECEIVER_BSC, AMOUNT);
        
        console.log("Sent", AMOUNT, "ETH from Sepolia to BSC to receiver", RECEIVER_BSC);
        
        vm.stopBroadcast();
    }
    
    receive() external payable {}
}
