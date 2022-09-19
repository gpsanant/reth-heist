// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Test.sol";

import "../src/RethMintAaveLoan.sol";
import "../src/RethMintEulerLoan.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";
import {RocketNodeDistributorInterface as INodeDistributor} from "@rocketpool/contracts/interfaces/node/RocketNodeDistributorInterface.sol";

contract MintAave is
    Script, Test
{
    Vm cheats = Vm(HEVM_ADDRESS);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    //performs basic deployment before each test
    function run() external {
        emit log_uint(address(msg.sender).balance);
        vm.startBroadcast();
        RethMintAaveLoan rm = new RethMintAaveLoan(ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5));
        rm.shoobeekFull(10 ether);
        vm.stopBroadcast();

        emit log_uint(WETH.balanceOf(address(rm)));
    }
}

contract MintEuler is
    Script, Test
{
    Vm cheats = Vm(HEVM_ADDRESS);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    RethMintEulerLoan rm = RethMintEulerLoan(0x321c7DB15c33b93DD907fB2803a23275123D5c7b);
    //performs basic deployment before each test
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_UINT");
        vm.startBroadcast(deployerPrivateKey);
        rm.shoobeekFull(150 ether);
        vm.stopBroadcast();
        emit log_uint(WETH.balanceOf(address(rm)));
    }
}


//forge script script/Heist.s.sol:Heist --rpc-url $FORK_URL -vvvv