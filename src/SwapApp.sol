// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "./interfaces/IV2Router02.sol";
import "./interfaces/IV2Factory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {
    using SafeERC20 for IERC20;

    address public V2Router02Address;
    address public V2FactoryAddress;

    event SwapTokens(address tokenIn_, address tokenOut_, uint256 amountIn_, uint256 amountOut_);

    error InvalidPath(address[] path_);

    constructor(address V2Router02Address_, address V2FactoryAddress_) {
        V2Router02Address = V2Router02Address_;
        V2FactoryAddress = V2FactoryAddress_;
    }

    function swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_) external {
        if (!_validPath(path_)) {
            revert InvalidPath(path_);
        }

        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(path_[0]).approve(V2Router02Address, amountIn_);

        uint256[] memory amounts_ = IV2Router02(V2Router02Address)
            .swapExactTokensForTokens(amountIn_, amountOutMin_, path_, msg.sender, deadline_);

        emit SwapTokens(path_[0], path_[path_.length - 1], amountIn_, amounts_[amounts_.length - 1]);
    }

    function _validPath(address[] memory path) private view returns (bool) {
        require(path.length >= 2, "Invalid path");

        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = IV2Factory(V2FactoryAddress).getPair(path[i], path[i + 1]);
            if (pair == address(0)) {
                return false;
            }
        }

        return true;
    }
}
