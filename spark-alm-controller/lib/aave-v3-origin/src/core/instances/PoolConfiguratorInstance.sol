// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PoolConfigurator, IPoolAddressesProvider, IPool, VersionedInitializable} from 'aave-v3-core/contracts/protocol/pool/PoolConfigurator.sol';

contract PoolConfiguratorInstance is PoolConfigurator {
  uint256 public constant CONFIGURATOR_REVISION = 3;

  /// @inheritdoc VersionedInitializable
  function getRevision() internal pure virtual override returns (uint256) {
    return CONFIGURATOR_REVISION;
  }

  function initialize(IPoolAddressesProvider provider) public virtual override initializer {
    _addressesProvider = provider;
    _pool = IPool(_addressesProvider.getPool());
  }
}
