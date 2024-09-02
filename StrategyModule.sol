// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract StrategyModule is Ownable {
    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal predictionFeed;

    uint256 public maxGasPrice; // Максимально допустимая цена газа для торговли

    constructor(
        address _priceFeed,
        address _predictionFeed,
        uint256 _maxGasPrice
    ) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        predictionFeed = AggregatorV3Interface(_predictionFeed);
        maxGasPrice = _maxGasPrice;
    }

    // Настройка нового ценового оракула
    function setPriceFeed(address _priceFeed) external onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Настройка нового оракула для предсказаний
    function setPredictionFeed(address _predictionFeed) external onlyOwner {
        predictionFeed = AggregatorV3Interface(_predictionFeed);
    }

    // Настройка максимальной цены газа
    function setMaxGasPrice(uint256 _maxGasPrice) external onlyOwner {
        maxGasPrice = _maxGasPrice;
    }

    // Получение текущих данных о цене ETH/USD
    function getETHPrice() internal view returns (uint256) {
        (, int256 price, , ,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return uint256(price);
    }

    // Получение предсказаний от AI
    function getPrediction() internal view returns (uint256) {
        (, int256 prediction, , ,) = predictionFeed.latestRoundData();
        require(prediction > 0, "Invalid prediction data");
        return uint256(prediction);
    }

    // Оценка возможности входа в сделку
    function evaluateEntry(
        address token,
        uint256 amount,
        uint256 ethAmount
    ) external view returns (bool, uint256, uint256) {
        uint256 ethPriceUSD = getETHPrice(); // Получение текущей цены ETH в USD
        uint256 predictionValue = getPrediction(); // Получение предсказания от AI

        // Логика принятия решений
        bool shouldEnter = predictionValue > 0;  // ( AI-предсказание)
        uint256 adjustedAmount = amount;  // Изначально устанавливаем сумму равной входной сумме

        // Логика оптимизации суммы
        if (ethAmount > 0) {
            uint256 ethBalance = address(this).balance; // Получаем баланс контракта в ETH
            uint256 maxAmount = ethBalance * ethPriceUSD / ethAmount; // Рассчитываем максимально возможную сумму в токенах

            if (maxAmount < adjustedAmount) {
            adjustedAmount = maxAmount; // Устанавливаем сумму равной максимально возможной сумме
            }
        }
        uint256 currentGasPrice = tx.gasprice;

        // Проверка, не превышает ли текущая цена газа максимально допустимую
        require(currentGasPrice <= maxGasPrice, "Gas price too high");

        return (shouldEnter, adjustedAmount, maxGasPrice);
    }
}
