pragma solidity ^0.7.0;

interface Wrapper {
    function wrap(uint256 amount) external returns (uint256);
}