pragma solidity ^0.7.0;

import "./interfaces/ICurve.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";
import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import "@balancer-labs/v2-vault/contracts/interfaces/IFlashLoanRecipient.sol";

interface IWrapper is IERC20 {
    function wrap(uint256 amount) external returns (uint256);
}

contract RethHeistBalancerLoan is IFlashLoanRecipient {
    address private immutable god;
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IERC20 private constant stETH = IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IWrapper private constant wstETH = IWrapper(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);

    ICurve private constant stETHETH = ICurve(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);
    ICurve private constant wstETHrETH = ICurve(0x447Ddd4960d9fdBF6af9a790560d0AF76795CB08);

    event Here();

    constructor() {
        god = msg.sender;
        stETH.approve(address(wstETH), type(uint256).max);
        wstETH.approve(address(wstETHrETH), type(uint256).max);
        rETH.approve(msg.sender, type(uint256).max);
    }

    receive() external payable {}

    function swapAndBurn(
        uint256 amount
    ) external {
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = IERC20(address(rETH));
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        vault.flashLoan(this, tokens, amounts, hex"");
    }

    function receiveFlashLoan(
        IERC20[] memory,
        uint256[] memory amounts,
        uint256[] memory,
        bytes memory
    ) external override {
        require(msg.sender == address(vault), "not vault");
        //burn loaned rETH and get ETH
        rETH.burn(amounts[0]);
        //trade ETH for stETH, get at least the balance back
        uint256 stETHOut = stETHETH.exchange{value: address(this).balance}(0, 1, address(this).balance, address(this).balance);
        //stETH -> wstETH
        uint256 wstETHOut = wstETH.wrap(stETHOut);
        //trade wstETH for rETH, get at least loaned amount back
        wstETHrETH.exchange(1, 0, wstETHOut, amounts[0]);
        //get rETH back to vault
        rETH.transfer(address(vault), amounts[0]);
    }
}