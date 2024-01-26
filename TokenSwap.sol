// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Add the line below to suppress the warnings
//pragma abicoder v2;

import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract TokenSwap is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public exchangeRate; // 1 Token A = exchangeRate Token B

    event Swap(address indexed user, uint256 amountA, uint256 amountB);

    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _exchangeRate
    ) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        exchangeRate = _exchangeRate;
    }

    function swapAToB(uint256 amountA) external {
        uint256 amountB = amountA * exchangeRate;
        _swap(tokenA, tokenB, amountA, amountB);
    }

    function swapBToA(uint256 amountB) external {
        uint256 amountA = amountB / exchangeRate;
        _swap(tokenB, tokenA, amountB, amountA);
    }

    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountFrom,
        uint256 amountTo
    ) internal {
        require(amountFrom > 0, "Amount must be greater than zero");
        require(fromToken.balanceOf(msg.sender) >= amountFrom, "Insufficient balance");

        fromToken.safeTransferFrom(msg.sender, address(this), amountFrom);
        toToken.safeTransfer(msg.sender, amountTo);

        emit Swap(msg.sender, amountFrom, amountTo);
    }

    function setExchangeRate(uint256 newRate) external onlyOwner {
        exchangeRate = newRate;
    }
}
