// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "src/ETHBridge.sol";

contract DeployETHBSC is Script {
    
    address constant SEPOLIA_ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    
    address constant BSC_ROUTER = 0xE1053aE1857476f36A3C62580FF9b016E8EE8F6f;
    
    uint64 constant SEPOLIA_CHAIN_ID = 16015286601757825753;
    
    uint64 constant BSC_CHAIN_ID = 13264668187771770619;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ETHBridge on Sepolia
        ETHBridge sepoliaBridge = new ETHBridge(SEPOLIA_ROUTER, BSC_CHAIN_ID);
        console.log("ETHBridge deployed on Sepolia at:", address(sepoliaBridge));

        // Deploy ETHBridge on BSC
        ETHBridge bscBridge = new ETHBridge(BSC_ROUTER, SEPOLIA_CHAIN_ID);
        console.log("ETHBridge deployed on BSC at:", address(bscBridge));

        vm.stopBroadcast();
    }
}
