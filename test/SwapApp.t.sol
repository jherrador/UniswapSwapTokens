// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../src/SwapApp.sol";
import "../src/interfaces/IV2Factory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract SwapAppTest is Test {
    SwapApp app;
    address V2Router02Address = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address V2FactoryAddress = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
    address user = 0x094357A38EDd84501Ac438590531EeBDe864cC13;

    function setUp() public {
        app = new SwapApp(V2Router02Address, V2FactoryAddress);
    }

    function testHasBeenDeployedCorrectly() public view {
        assert(app.V2Router02Address() == V2Router02Address);
    }

    function testSwapTokensCorrectly() public {
        uint256 deadline_ = block.timestamp + 30 seconds;
        address usdcTokenAddress_ = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
        address usdbcTokenAddress_ = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress_).decimals();
        uint256 amountOutMin_ = 4 * 10 ^ IERC20Metadata(usdbcTokenAddress_).decimals();
        uint256 userUsdcBalanceBefore_ = IERC20(usdcTokenAddress_).balanceOf(user);
        uint256 userUsdbcBalanceBefore_ = IERC20(usdbcTokenAddress_).balanceOf(user);

        vm.startPrank(user);

        IERC20(usdcTokenAddress_).approve(address(app), amountIn_);

        address[] memory path_ = new address[](2);
        path_[0] = usdcTokenAddress_;
        path_[1] = usdbcTokenAddress_;
        app.swapTokens(amountIn_, amountOutMin_, path_, deadline_);

        assert(IERC20(usdcTokenAddress_).balanceOf(user) == userUsdcBalanceBefore_ - amountIn_);
        assert(IERC20(usdbcTokenAddress_).balanceOf(user) >= userUsdbcBalanceBefore_ + amountOutMin_);
        vm.stopPrank();
    }

    function testSwapTokensRevertWrongMinAmount() public {
        uint256 deadline_ = block.timestamp + 30 seconds;
        address usdcTokenAddress_ = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
        address usdbcTokenAddress_ = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress_).decimals();
        uint256 amountOutMin_ = 6 * 10 ^ IERC20Metadata(usdbcTokenAddress_).decimals();

        vm.startPrank(user);

        IERC20(usdcTokenAddress_).approve(address(app), amountIn_);

        address[] memory path_ = new address[](2);
        path_[0] = usdcTokenAddress_;
        path_[1] = usdbcTokenAddress_;
        vm.expectRevert("UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        app.swapTokens(amountIn_, amountOutMin_, path_, deadline_);

        vm.stopPrank();
    }

    function testSwapTokensRevertWrongPath() public {
        uint256 deadline_ = block.timestamp + 30 seconds;
        address usdcTokenAddress_ = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
        address usdbcTokenAddress_ = 0xA2b9436D567A740357ca432b35582E93191e6a2F;
        uint256 amountIn_ = 5 * 10 ^ IERC20Metadata(usdcTokenAddress_).decimals();
        uint256 amountOutMin_ = 4 * 10 ^ IERC20Metadata(usdbcTokenAddress_).decimals();

        vm.startPrank(user);

        IERC20(usdcTokenAddress_).approve(address(app), amountIn_);

        address[] memory path_ = new address[](2);
        path_[0] = usdcTokenAddress_;
        path_[1] = usdbcTokenAddress_;

        vm.expectRevert();
        app.swapTokens(amountIn_, amountOutMin_, path_, deadline_);

        vm.stopPrank();
    }
}
