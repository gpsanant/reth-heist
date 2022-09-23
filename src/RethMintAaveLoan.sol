pragma solidity ^0.7.0;
pragma abicoder v2;


import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import "@balancer-labs/v2-vault/contracts/interfaces/IAsset.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";
import {RocketDepositPoolInterface as IDepositPool} from "@rocketpool/contracts/interfaces/deposit/RocketDepositPoolInterface.sol";


import "./interfaces/AaveInterfaces.sol";
import "./FlashLoanReceiverBase.sol";



contract RethMintAaveLoan is FlashLoanReceiverBase {
    address private immutable god;
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IDepositPool private rocketDepositPool = IDepositPool(0x2cac916b2A963Bf162f076C0a8a4a8200BCFBfb4);
    event number(uint256);
    constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) {
        god = msg.sender;
        WETH.approve(_addressProvider.getLendingPool(), type(uint256).max);
        rETH.approve(address(vault), type(uint256).max);
        WETH.approve(msg.sender, type(uint256).max);
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
        bytes calldata
    )
        external
        override
        returns (bool)
    {   
        //unwrap weth
        WETH.withdraw(amounts[0]);
        //deposit eth into rocket pool, get rETH
        rocketDepositPool.deposit{value: address(this).balance}();
        //swap all minted rETH for WETH
        IVault.SingleSwap memory singleSwap = IVault.SingleSwap({
            poolId: bytes32(0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112), //WETH/rETH
            kind: IVault.SwapKind.GIVEN_IN,
            assetIn: IAsset(address(rETH)),
            assetOut: IAsset(address(WETH)),
            amount: rETH.balanceOf(address(this)),
            userData: hex""
        });
        emit number(rETH.balanceOf(address(this)));
        
        IVault.FundManagement memory funds = IVault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });

        vault.swap(
            singleSwap,
            funds,
            amounts[0]+premiums[0], //get at least loan + fee back //todo: set limit here?
            block.timestamp
        );

        emit number(WETH.balanceOf(address(this)));

        return true;
    }

    function mintAndSwap(uint256 amount) public {
        address[] memory assets = new address[](1);
        assets[0] = address(WETH);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        LENDING_POOL.flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            hex"",
            0
        );
    }

    function withdrawWeth(uint256 amount) public {
        payable(god).transfer(amount);
    }
}