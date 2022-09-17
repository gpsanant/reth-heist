// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Test.sol";

import "../src/RethHeistAaveLoan.sol";
import "../src/RethHeistBalancerLoan.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";
import {RocketNodeDistributorInterface as INodeDistributor} from "@rocketpool/contracts/interfaces/node/RocketNodeDistributorInterface.sol";


contract HeistAave is
    Script, Test
{
    Vm cheats = Vm(HEVM_ADDRESS);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    //performs basic deployment before each test
    function run() external {
        emit log_uint(address(msg.sender).balance);
        vm.startBroadcast();
        RethHeistAaveLoan rh = new RethHeistAaveLoan(ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5));
        // INodeDistributor(0x0B70B578aBd96AAb5e80D24D1f3C28DbdE14356a).distribute();
        // INodeDistributor(0x9A7E7428B61048947F37A68D32CDD9B8486E7550).distribute();
        // INodeDistributor(0xCcDF5B84F3da928AfA71446d92ADA9e7C7A1F2Ba).distribute();
        vm.stopBroadcast();

        uint256 amountWeth = rETH.getTotalCollateral(); // this is an overestimate
        emit log_named_uint("amount weth", amountWeth);
        uint256 amountReth = rETH.getRethValue(rETH.getTotalCollateral());
        emit log_named_uint("amount reth", amountReth);
        // emit log_uint(address(msg.sender).balance);
        //     // 1350642958146299193
        vm.broadcast();
        rh.shoobeekFull(amountWeth, amountReth);
        emit log_uint(WETH.balanceOf(address(rh)));
    }
}


contract HeistBal is
    Script, Test
{
    Vm cheats = Vm(HEVM_ADDRESS);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    //performs basic deployment before each test
    function run() external {
        emit log_uint(address(msg.sender).balance);
        vm.startBroadcast();
        RethHeistBalancerLoan rh = new RethHeistBalancerLoan();
        vm.stopBroadcast();

        uint256 amountWeth = rETH.getTotalCollateral(); // this is an overestimate
        emit log_named_uint("amount weth", amountWeth);
        uint256 amountReth = rETH.getRethValue(rETH.getTotalCollateral());
        emit log_named_uint("amount reth", amountReth);
        vm.broadcast();
        rh.shoobeekFull(amountReth);
        emit log_uint(rETH.balanceOf(address(rh)));
    }
}

//forge script script/Heist.s.sol:Heist --rpc-url $FORK_URL -vvvv