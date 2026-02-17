// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../src/SwapAppV3.sol";
import "../src/libraries/Path.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract SwapAppV3Test is Test {
    SwapAppV3 app;
    address IV3SwapRouterAddress = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address IUniswapV3FactoryAddress = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
    address usdcTokenAddress = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address usdbcTokenAddress = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;
    address usdtTokenAddress = 0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2;
    address user = 0x048ef1062cbb39B338Ac2685dA72adf104b4cEF5;

    function setUp() public {
        app = new SwapAppV3(IV3SwapRouterAddress, IUniswapV3FactoryAddress);
    }

    function testHasBeenDeployedCorrectly() public view {
        assert(app.IV3SwapRouterAddress() == IV3SwapRouterAddress);
    }

    function testSwapTokensCorrectly() public {
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress).decimals();
        uint256 amountOutMin_ = 4 * 10 ^ IERC20Metadata(usdbcTokenAddress).decimals();
        uint256 userUsdcBalanceBefore_ = IERC20(usdcTokenAddress).balanceOf(user);
        uint256 userUsdbcBalanceBefore_ = IERC20(usdbcTokenAddress).balanceOf(user);
        uint24 fee_ = 100;

        vm.startPrank(user);

        IERC20(usdcTokenAddress).approve(address(app), amountIn_);

        bytes memory path_ = abi.encodePacked(usdcTokenAddress, fee_, usdbcTokenAddress);

        console.logBytes(path_);

        app.swapTokens(amountIn_, amountOutMin_, path_, user);

        assert(IERC20(usdcTokenAddress).balanceOf(user) == userUsdcBalanceBefore_ - amountIn_);
        assert(IERC20(usdbcTokenAddress).balanceOf(user) >= userUsdbcBalanceBefore_ + amountOutMin_);
        vm.stopPrank();
    }

    function testSwapTokensWith2HoopsCorrectly() public {
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress).decimals();
        uint256 amountOutMin_ = 4 * 10 ^ IERC20Metadata(usdtTokenAddress).decimals();
        uint256 userUsdcBalanceBefore_ = IERC20(usdcTokenAddress).balanceOf(user);
        uint256 userUsdtcBalanceBefore_ = IERC20(usdtTokenAddress).balanceOf(user);
        uint24 fee_ = 100;

        vm.startPrank(user);

        IERC20(usdcTokenAddress).approve(address(app), amountIn_);

        bytes memory path_ = abi.encodePacked(usdcTokenAddress, fee_, usdbcTokenAddress, fee_, usdtTokenAddress);

        console.logBytes(path_);

        app.swapTokens(amountIn_, amountOutMin_, path_, user);

        assert(IERC20(usdcTokenAddress).balanceOf(user) == userUsdcBalanceBefore_ - amountIn_);
        assert(IERC20(usdtTokenAddress).balanceOf(user) >= userUsdtcBalanceBefore_ + amountOutMin_);
        vm.stopPrank();
    }

    function testSwapTokensWith2HoopsRevertsWrongPath() public {
        address skyaTokenAddress_ = 0x623cD3a3EdF080057892aaF8D773Bbb7A5C9b6e9;
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress).decimals();
        uint256 amountOutMin_ = 4 * 10 ^ IERC20Metadata(skyaTokenAddress_).decimals();
        uint24 fee_ = 100;

        vm.startPrank(user);

        IERC20(usdcTokenAddress).approve(address(app), amountIn_);

        bytes memory path_ = abi.encodePacked(usdcTokenAddress, fee_, skyaTokenAddress_, fee_, usdbcTokenAddress);

        console.logBytes(path_);
        vm.expectRevert("Invalid Pool");
        app.swapTokens(amountIn_, amountOutMin_, path_, user);
        vm.stopPrank();
    }

    function testSwapTokensRevertWrongMinAmount() public {
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress).decimals();
        uint256 amountOutMin_ = 6 * 10 ^ IERC20Metadata(usdbcTokenAddress).decimals();
        uint24 fee_ = 100;

        vm.startPrank(user);

        IERC20(usdcTokenAddress).approve(address(app), amountIn_);

        bytes memory path_ = abi.encodePacked(usdcTokenAddress, fee_, usdbcTokenAddress);

        console.logBytes(path_);
        vm.expectRevert("Too little received");
        app.swapTokens(amountIn_, amountOutMin_, path_, user);
        vm.stopPrank();
    }

    function testSwapTokensRevertWrongPath() public {
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress).decimals();
        uint256 amountOutMin_ = 6 * 10 ^ IERC20Metadata(usdbcTokenAddress).decimals();
        uint24 fee_ = 1;

        vm.startPrank(user);

        IERC20(usdcTokenAddress).approve(address(app), amountIn_);

        bytes memory path_ = abi.encodePacked(usdcTokenAddress, fee_, usdbcTokenAddress);

        console.logBytes(path_);
        vm.expectRevert("Invalid Pool");
        app.swapTokens(amountIn_, amountOutMin_, path_, user);
        vm.stopPrank();
    }
}
