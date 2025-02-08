// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "src/ETHBridge.sol";

contract SendETHBSCToSepolia is Script {
    address constant ETH_BRIDGE_BSC = vm.envAddress("ETH_BRIDGE_BSC");
    
    address constant RECEIVER_SEPOLIA = vm.envAddress("RECEIVER_SEPOLIA");
    
    // Amount to send in wei (Replace with desired amount)
    uint256 constant AMOUNT = 0.1 ether;

    function run() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);
        
        ETHBridge bridge = ETHBridge(ETH_BRIDGE_BSC);
        uint256 fee = bridge.getFee(RECEIVER_SEPOLIA, AMOUNT);
        uint256 totalAmount = AMOUNT + fee;

        bridge.send{value: totalAmount}(RECEIVER_SEPOLIA, AMOUNT);
        
        console.log("Sent", AMOUNT, "ETH from BSC to Sepolia to receiver", RECEIVER_SEPOLIA);
        
        vm.stopBroadcast();
    }
    
    receive() external payable {}
}
