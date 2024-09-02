// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RiskManager is Ownable {
    uint256 public minAmount;
    uint256 public maxSlippage;
    uint256 public maxGasPrice;

    constructor(uint256 _minAmount, uint256 _maxSlippage, uint256 _maxGasPrice) {
        minAmount = _minAmount;
        maxSlippage = _maxSlippage;
        maxGasPrice = _maxGasPrice;
    }

    function setMinAmount(uint256 _minAmount) external onlyOwner {
        minAmount = _minAmount;
    }

    function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {
        maxSlippage = _maxSlippage;
    }

    function setMaxGasPrice(uint256 _maxGasPrice) external onlyOwner {
        maxGasPrice = _maxGasPrice;
    }

    function isValidAmount(uint256 amount) external view returns (bool) {
        return amount >= minAmount;
    }

    function isGasPriceAcceptable(uint256 gasPrice) external view returns (bool) {
        return gasPrice <= maxGasPrice;
    }
}
