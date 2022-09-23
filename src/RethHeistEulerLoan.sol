pragma solidity ^0.7.0;
pragma abicoder v2;


import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import "@balancer-labs/v2-vault/contracts/interfaces/IAsset.sol";
import {RocketTokenRETHInterface as IRETH} from "@rocketpool/contracts/interfaces/token/RocketTokenRETHInterface.sol";
import {RocketDepositPoolInterface as IDepositPool} from "@rocketpool/contracts/interfaces/deposit/RocketDepositPoolInterface.sol";

interface IFlashBorrower {
    function onFlashLoan(bytes calldata data) external;
}

interface IFlashLender {
    function flashLoan(uint amount, bytes calldata data) external;
}

contract RethHeistEulerLoan is IFlashBorrower {
    address private immutable god;
    IFlashLender lender = IFlashLender(0x62e28f054efc24b26A794F5C1249B6349454352C);
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IRETH private constant rETH = IRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IDepositPool private rocketDepositPool = IDepositPool(0x2cac916b2A963Bf162f076C0a8a4a8200BCFBfb4);
    constructor() {
        god = msg.sender;
        WETH.approve(address(lender), type(uint256).max);
        rETH.approve(address(vault), type(uint256).max);
        WETH.approve(msg.sender, type(uint256).max);
    }

    receive() external payable {}

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function onFlashLoan(bytes calldata data)
        external override
    {   
        require(msg.sender == 0x27182842E098f60e3D576794A5bFFb0777E025d3, "not euler");
        (uint256 amountWeth, uint256 amountReth) = abi.decode(data, (uint, uint));

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
            amountWeth, //todo: set limit here?
            block.timestamp
        );

        rETH.burn(
            amountReth //todo: outputted from swap?
        );

        address(WETH).call{value: address(this).balance}("");

        WETH.transfer(msg.sender, amountWeth);
    }

    function swapAndBurn(uint256 amountWeth, uint256 amountReth) public {
        lender.flashLoan(amountWeth, abi.encode(amountWeth, amountReth));
    }
}