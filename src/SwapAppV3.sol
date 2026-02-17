// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "./interfaces/IV3SwapRouter.sol";
import "./libraries/Path.sol";
import "./interfaces/IUniswapV3Factory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapAppV3 {
    using SafeERC20 for IERC20;
    using Path for bytes;

    address public IV3SwapRouterAddress;
    address public IUniswapV3FactoryAddress;

    event SwapTokens(address tokenIn_, address tokenOut_, uint256 amountIn_, uint256 amountOut_, address receiver_);

    constructor(address IV3SwapRouterAddress_, address IUniswapV3FactoryAddress_) {
        IV3SwapRouterAddress = IV3SwapRouterAddress_;
        IUniswapV3FactoryAddress = IUniswapV3FactoryAddress_;
    }

    function swapTokens(uint256 amountIn_, uint256 amountOutMin_, bytes memory path_, address receiver_) external {
        require(_isValidPath(path_), "Invalid Path");
        (address tokenInAddress_, address tokenOutAddress_,) = path_.decodeFirstPool();

        if (path_.hasMultiplePools()) {
            tokenOutAddress_ = _getFinalToken(path_);
        }

        IERC20(tokenInAddress_).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(tokenInAddress_).approve(IV3SwapRouterAddress, amountIn_);

        IV3SwapRouter.ExactInputParams memory params = IV3SwapRouter.ExactInputParams({
            path: path_, recipient: receiver_, amountIn: amountIn_, amountOutMinimum: amountOutMin_
        });

        uint256 amountsOut_ = IV3SwapRouter(IV3SwapRouterAddress).exactInput(params);

        emit SwapTokens(tokenInAddress_, tokenOutAddress_, amountIn_, amountsOut_, receiver_);
    }

    function _getFinalToken(bytes memory path) private pure returns (address) {
        while (path.hasMultiplePools()) {
            path = path.skipToken();
        }

        (, address tokenOut,) = path.decodeFirstPool();
        return tokenOut;
    }

    function _isValidPath(bytes memory path_) internal view returns (bool) {
        (address tokenInAddress_, address tokenOutAddress_, uint24 fee_) = path_.decodeFirstPool();
        require(_validPool(tokenInAddress_, tokenOutAddress_, fee_), "Invalid Pool");

        while (path_.hasMultiplePools()) {
            path_ = path_.skipToken();
            (tokenInAddress_, tokenOutAddress_, fee_) = path_.decodeFirstPool();
            require(_validPool(tokenInAddress_, tokenOutAddress_, fee_), "Invalid Pool");
        }

        return true;
    }

    function _validPool(address tokenInAddress_, address tokenOutAddress_, uint24 fee_) private view returns (bool) {
        address poolAddress =
            IUniswapV3Factory(IUniswapV3FactoryAddress).getPool(tokenInAddress_, tokenOutAddress_, fee_);

        if (poolAddress == address(0)) return false;

        return true;
    }
}
