pragma solidity ^0.7.0;
pragma abicoder v2;


import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import "@balancer-labs/v2-vault/contracts/interfaces/IAsset.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";

import "./interfaces/AaveInterfaces.sol";
import "./FlashLoanReceiverBase.sol";


contract RethHeistAaveLoan is FlashLoanReceiverBase {
    address private immutable god;
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) {
        god = msg.sender;
        WETH.approve(_addressProvider.getLendingPool(), type(uint256).max);
        WETH.approve(address(vault), type(uint256).max);
    }

    receive() external payable {}

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address[] calldata,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        uint256 amountReth;
        assembly {
            amountReth := calldataload(params.offset)
        }

        IVault.SingleSwap memory singleSwap = IVault.SingleSwap({
            poolId: bytes32(0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112), //WETH/rETH
            kind: IVault.SwapKind.GIVEN_OUT,
            assetIn: IAsset(address(WETH)),
            assetOut: IAsset(address(rETH)),
            amount: amountReth,
            userData: hex""
        });

        IVault.FundManagement memory funds = IVault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });

        vault.swap(
            singleSwap,
            funds,
            amounts[0], //todo: set limit here?
            block.timestamp
        );

        rETH.burn(
            amountReth //todo: outputted from swap?
        );

        address(WETH).call{value: address(this).balance}("");

        return true;
    }

    function shoobeekFull(uint256 amountWeth, uint256 amountReth) public {
        address[] memory assets = new address[](1);
        assets[0] = address(WETH);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amountWeth;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        bytes memory params = abi.encodePacked(amountReth);

        LENDING_POOL.flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            params,
            0
        );
    }

    function withdrawWeth(uint256 amount) public {
        payable(god).transfer(amount);
    }
}