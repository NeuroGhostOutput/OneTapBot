// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AnalyticsModule is Ownable {
    struct Trade {
        address user;
        address token;
        uint256 amount;
        uint256 gasPrice;
        uint256 timestamp;
    }

    Trade[] public trades;

    function recordTrade(address user, address token, uint256 amount, uint256 gasPrice) external onlyOwner {
        trades.push(Trade(user, token, amount, gasPrice, block.timestamp));
    }

    function getTradeHistory() external view returns (Trade[] memory) {
        return trades;
    }

    function getLastTrade() external view returns (Trade memory) {
        return trades[trades.length - 1];
    }
}
