// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TradeManager.sol";
import "./RiskManager.sol";
import "./SecurityModule.sol";
import "./AnalyticsModule.sol";
import "./StrategyModule.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SniperBot is Ownable {
    TradeManager private tradeManager;
    RiskManager private riskManager;
    SecurityModule private securityModule;
    AnalyticsModule private analyticsModule;
    StrategyModule private strategyModule;

    constructor(
        address _tradeManager,
        address _riskManager,
        address _securityModule,
        address _analyticsModule,
        address _strategyModule
    ) {
        tradeManager = TradeManager(_tradeManager);
        riskManager = RiskManager(_riskManager);
        securityModule = SecurityModule(_securityModule);
        analyticsModule = AnalyticsModule(_analyticsModule);
        strategyModule = StrategyModule(_strategyModule);
    }

    function snipe(address token, uint256 amountIn) external onlyOwner payable {
        require(!securityModule.isBlacklisted(token), "Token is blacklisted");
        require(riskManager.isValidAmount(amountIn), "Invalid amount for trade");

        (bool shouldExecute, uint256 adjustedAmount, uint256 maxGasPrice) = strategyModule.evaluateEntry(token, amountIn, msg.value);
        require(shouldExecute, "Trade conditions not met");

        uint256 currentGasPrice = tx.gasprice;
        require(currentGasPrice <= maxGasPrice, "Gas price too high for this trade");

        tradeManager.executeTrade{value: msg.value}(token, adjustedAmount);
        analyticsModule.recordTrade(msg.sender, token, adjustedAmount, currentGasPrice);
    }

    function withdraw() external onlyOwner {
        tradeManager.withdrawFunds(owner());
    }

    function withdrawTokens(address token) external onlyOwner {
        tradeManager.withdrawTokens(token, owner());
    }

    receive() external payable {}
}


