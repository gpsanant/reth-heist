pragma solidity ^0.7.0;

import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import {IFlashLoanRecipient as IBalancerFlashLoanRecipient} from "@balancer-labs/v2-vault/contracts/interfaces/IFlashLoanRecipient.sol";

contract RethHeist is IBalancerFlashLoanRecipient {
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    

    constructor(IERC20[] calldata tokens, uint256[] calldata amounts){
        vault.flashLoan(this, tokens, amounts, hex"");
        
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts
    ) external override {
        require(msg.sender == address(vault), "Callback must be vault");
    }
}