// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;



import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Test.sol";


contract SlashRPL is
    Script, Test
{
    Vm cheats = Vm(HEVM_ADDRESS);
    // RocketNodeManagerInterface nodeManager = RocketNodeManagerInterface(0x67CdE7AF920682A29fcfea1A179ef0f30F48Df3e);
    // RocketNodeDepositInterface nodeDeposit = RocketNodeDepositInterface(0x1Cc9cF5586522c6F483E84A19c3C2B0B6d027bF0);
    // RocketMinipoolManagerInterface minipoolManager = RocketMinipoolManagerInterface(0x84D11B65E026F7aA08F5497dd3593fb083410B71);

    //performs basic deployment before each test
    function run() external {
        // vm.startBroadcast();

        // vm.stopBroadcast();
    }
}

//forge script script/SlashRPL.s.sol:SlashRPL --rpc-url $RPC_URL -vvvv