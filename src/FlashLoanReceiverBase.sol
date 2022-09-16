pragma solidity ^0.7.0;

import {IFlashLoanReceiver, ILendingPoolAddressesProvider, ILendingPool} from "./interfaces/AaveInterfaces.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
  ILendingPool public immutable LENDING_POOL;

  constructor(ILendingPoolAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
    LENDING_POOL = ILendingPool(provider.getLendingPool());
  }
}