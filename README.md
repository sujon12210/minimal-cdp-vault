# Minimal CDP Vault

This repository demonstrates the core mechanics of decentralized lending. Users can lock up "Collateral" tokens to mint "Debt" tokens. If the value of their collateral drops below a specific threshold (150%), their position becomes eligible for liquidation.

## Mechanics
* **Collateralization Ratio**: Set at 150%. Users must provide $1.50 of collateral for every $1.00 borrowed.
* **Price Oracle**: Integrated with a simple owner-driven oracle (can be swapped for Chainlink).
* **Liquidation**: Liquidators can pay off a user's debt to receive the user's collateral at a 10% discount.

## Safety Features
* **ReentrancyGuard**: Prevents common exploit patterns during withdrawals and liquidations.
* **Over-collateralization Check**: Reverts any action that would put the vault in an under-collateralized state.
