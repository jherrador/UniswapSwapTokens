# 🔄 UniswapSwapTokens

![Ethereum](https://img.shields.io/badge/Ethereum-Blockchain-3C3C3D?logo=ethereum&logoColor=white)
![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.x-363636?logo=solidity)
![Uniswap](https://img.shields.io/badge/DEX-Uniswap-orange)
![License](https://img.shields.io/badge/License-Unlicensed-lightgrey)

UniswapSwapTokens is a Solidity-based protocol that enables ERC20 token swaps through **Uniswap V2 and Uniswap V3**.

The project implements two versions of the swap logic:
- 🔁 Integration with **Uniswap V2 Router**
- ⚡ Integration with **Uniswap V3 Router**

A key feature of this implementation is the **validation of the swap path**, including support for multi-hop routes, ensuring correctness and security before execution.

---

## 🧠 Project Overview

UniswapSwapTokens allows users (or external contracts) to swap ERC20 tokens via Uniswap liquidity pools while:

- Supporting both **Uniswap V2 and V3**
- Validating swap paths before execution
- Supporting multi-hop swaps (token A → token B → token C)
- Ensuring proper token approvals and routing logic

This project demonstrates practical integration with real DeFi infrastructure.

---

## 🏗️ Core Features

### 🔁 Uniswap V2 Integration
- Uses Uniswap V2 Router
- Supports direct and multi-hop swaps
- Path validation before execution
- Slippage protection parameters

### ⚡ Uniswap V3 Integration
- Uses Uniswap V3 SwapRouter
- Encoded path validation
- Fee tier handling (e.g., 0.05%, 0.3%, 1% pools)
- Supports advanced routing logic

### 🛡️ Path Validation Logic
- Verifies that swap path is valid
- Ensures minimum path length
- Supports multi-hop swaps
- Prevents malformed routes

### 💰 ERC20 Compatibility
- Works with standard ERC20 tokens
- Requires prior token approval
- Transfers tokens securely before swap

---

## 📦 Project Structure

```text
.
├── lib/
├── script/
├── src/
└── test/
```

- `src/` — Swap protocol smart contracts (V2 & V3)
- `test/` — Unit and integration tests
- `script/` — Deployment scripts
- `lib/` — Dependencies

---

## 🛠 Tech Stack

- **Solidity**
- **Uniswap V2**
- **Uniswap V3**
- **Foundry**

---

## 🚀 Getting Started

### Prerequisites

- Foundry installed
- EVM RPC provider (tests are prepared for Base Chain)
- ERC20 tokens for testing

---

## 🧪 Build & Test

### Compile contracts

```bash
forge build
```

### Run tests

```bash
forge test
```

---

## 🔁 Example Swap Flow

1. User approves contract to spend Token A.
2. User calls swap function with:
   - Token input
   - Token output
   - Amount in
   - Minimum amount out
   - Swap path (including hops if needed)
3. Contract validates path.
4. Contract interacts with Uniswap Router (V2 or V3).
5. Tokens are swapped.
6. Output tokens are sent to the user.

---

## 🔮 Future Integrations & Enhancements

The protocol will have additional features such as:


### 💱 Multi-DEX Aggregation
- Integration with SushiSwap, Curve, Balancer
- Cross-DEX routing logic
- Best price execution

### 🛡️ Advanced Slippage Protection
- Dynamic slippage calculation
- TWAP price verification
- Oracle-based validation

---

## 📜 License

This project is currently unlicensed.
Consider adding an MIT License if publishing publicly.

---

## 👤 Author

Developed by **Javier Herrador** as part of his Solidity and DeFi development journey.
