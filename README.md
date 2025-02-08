# 🌉 ETHBridge

## 🚀 Overview
ETHBridge is a Solidity-based smart contract that enables cross-chain ETH transfers using Chainlink's Cross-Chain Interoperability Protocol (CCIP). This project provides a decentralized and secure mechanism for bridging ETH between different blockchain networks.

## 📁 Project Structure
```
├── foundry.toml          # 🛠 Foundry configuration file
├── lib                   # 📦 External dependencies
│   ├── ccip              # 🔗 Chainlink CCIP contracts
│   ├── chainlink-local   # 🔗 Local Chainlink implementation
│   ├── forge-std         # 📚 Foundry standard library
│   └── openzeppelin-contracts # 🔐 OpenZeppelin contracts
├── LICENSE               # 📜 Project license
├── mocks                 # 🎭 Mock contracts for testing
│   ├── MockCCIPRouter.t.sol
│   ├── MockCCIPSimulator.t.sol
│   ├── MockETHBridge.t.sol
│   └── MockWETH.t.sol
├── README.md             # 📖 Project documentation
├── remappings.txt        # 🔀 Dependency remappings
├── script                # 📜 Deployment and scripting
├── src                   # 📝 Source contracts
│   └── ETHBridge.sol     # 🌉 ETHBridge contract
└── test                  # 🧪 Testing suite
    └── ETHBridge.t.sol   # ✅ ETHBridge contract tests
```

## ✨ Features
- ✅ Uses Chainlink CCIP for cross-chain ETH transfers.
- 🔄 Supports native ETH bridging with automatic wrapping/unwrapping.
- ⚡ Implements secure and efficient transaction processing.
- 💰 Refunds excess ETH to the sender if overpaid.

## ⚙️ Installation
Ensure you have [Foundry](https://book.getfoundry.sh/) installed, then clone the repository and install dependencies:
```sh
git clone <repository_url>
cd eth-bridge
forge install
```

## 🔨 Compilation
Compile the smart contracts using Foundry:
```sh
forge build
```

## 🧪 Testing
Run the test suite:
```sh
forge test
```

## 🚀 Deployment
To deploy the contract, modify the script and run:
```sh
forge script script/DeployETHBridge.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## 🔄 Sending ETH Cross-Chain
### 🌍 From Sepolia to BSC
```sh
forge script script/SendETHSepoliaToBSC.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 🔗 From BSC to Sepolia
```sh
forge script script/SendETHBSCToSepolia.s.sol --rpc-url $BSC_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## 🛠 Environment Variables
Create a `.env` file with the following format:
```env
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
BSC_RPC_URL=https://bsc-dataseed.binance.org/
ETH_BRIDGE_SEPOLIA=0x1234567890abcdef1234567890abcdef12345678
ETH_BRIDGE_BSC=0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef
RECEIVER_ADDRESS=0xrecipientaddresshere
```

## 📜 License
This project is licensed under the BUSL-1.1 License.

