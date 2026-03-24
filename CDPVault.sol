// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./StableCoin.sol";

contract CDPVault is ReentrancyGuard {
    IERC20 public collateralToken;
    StableCoin public debtToken;
    
    uint256 public constant MIN_COLLATERAL_RATIO = 150; // 150%
    uint256 public ethPrice = 2000e18; // Mock price: 1 Collateral = 2000 USD

    struct Position {
        uint256 collateralAmount;
        uint256 debtAmount;
    }

    mapping(address => Position) public positions;

    constructor(address _collateral, address _debt) {
        collateralToken = IERC20(_collateral);
        debtToken = StableCoin(_debt);
    }

    function depositAndMint(uint256 _collateralAmount, uint256 _mintAmount) external nonReentrant {
        collateralToken.transferFrom(msg.sender, address(this), _collateralAmount);
        
        positions[msg.sender].collateralAmount += _collateralAmount;
        positions[msg.sender].debtAmount += _mintAmount;

        require(_isHealthy(msg.sender), "Insufficient collateralization");
        debtToken.mint(msg.sender, _mintAmount);
    }

    function liquidate(address _user) external nonReentrant {
        require(!_isHealthy(_user), "Position is still healthy");

        uint256 userDebt = positions[_user].debtAmount;
        uint256 userCollateral = positions[_user].collateralAmount;

        // Liquidator pays the debt
        debtToken.burnFrom(msg.sender, userDebt);
        
        // Liquidator takes collateral (In a real app, apply a liquidation bonus here)
        delete positions[_user];
        collateralToken.transfer(msg.sender, userCollateral);
    }

    function _isHealthy(address _user) internal view returns (bool) {
        Position memory pos = positions[_user];
        if (pos.debtAmount == 0) return true;

        uint256 collateralValue = (pos.collateralAmount * ethPrice) / 1e18;
        uint256 ratio = (collateralValue * 100) / pos.debtAmount;
        return ratio >= MIN_COLLATERAL_RATIO;
    }

    // Owner function to update mock price
    function updatePrice(uint256 _newPrice) external {
        ethPrice = _newPrice;
    }
}
