pragma solidity ^0.7.0;

import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import {IFlashLoanRecipient as IBalancerFlashLoanRecipient} from "@balancer-labs/v2-vault/contracts/interfaces/IFlashLoanRecipient.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";

contract RethHeist is IBalancerFlashLoanRecipient {
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IRETH private constant reth = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);

    constructor(IERC20[] memory tokens, uint256[] memory amounts){
        vault.flashLoan(this, tokens, amounts, hex"");
        
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == address(vault), "Callback must be vault");
    }
}