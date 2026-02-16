// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

interface IV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
}
