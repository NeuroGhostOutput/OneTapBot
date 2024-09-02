// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TradeManager is Ownable {
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;  // адрес Uniswap V2 Router
    address private constant SUSHISWAP_V2_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;  // адрес Sushiswap V2 Router

    IUniswapV2Router02 private uniswapRouter;
    IUniswapV2Router02 private sushiswapRouter;

    constructor() {
        uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
        sushiswapRouter = IUniswapV2Router02(SUSHISWAP_V2_ROUTER);
    }

    function executeTrade(address token, uint256 amountIn) external payable onlyOwner {
        uint256 uniswapPrice = getPriceFromUniswap(token, amountIn);
        uint256 sushiswapPrice = getPriceFromSushiswap(token, amountIn);

        // Арбитраж: выбираем лучший DEX
        if (uniswapPrice > sushiswapPrice) {
            executeUniswapTrade(token, amountIn);
        } else {
            executeSushiswapTrade(token, amountIn);
        }
    }

    function getPriceFromUniswap(address token, uint256 amountIn) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = token;
        uint256[] memory amounts = uniswapRouter.getAmountsOut(amountIn, path);
        return amounts[1];
    }

    function getPriceFromSushiswap(address token, uint256 amountIn) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = sushiswapRouter.WETH();
        path[1] = token;
        uint256[] memory amounts = sushiswapRouter.getAmountsOut(amountIn, path);
        return amounts[1];
    }

    function executeUniswapTrade(address token, uint256 amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = token;
        uint256 amountOutMin = (getPriceFromUniswap(token, amountIn) * 97) / 100;  // 3% проскальзывание
        uniswapRouter.swapExactETHForTokens{value: amountIn}(
            amountOutMin,
            path,
            owner(),
            block.timestamp + 300
        );
    }

    function executeSushiswapTrade(address token, uint256 amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = sushiswapRouter.WETH();
        path[1] = token;
        uint256 amountOutMin = (getPriceFromSushiswap(token, amountIn) * 97) / 100;  // 3% проскальзывание
        sushiswapRouter.swapExactETHForTokens{value: amountIn}(
            amountOutMin,
            path,
            owner(),
            block.timestamp + 300
        );
    }

    function withdrawFunds(address payable recipient) external onlyOwner {
        recipient.transfer(address(this).balance);
    }

    function withdrawTokens(address token, address recipient) external onlyOwner {
        IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable {}
}
