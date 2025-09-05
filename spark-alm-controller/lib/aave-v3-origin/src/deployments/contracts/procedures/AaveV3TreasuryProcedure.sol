// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ProxyAdmin} from 'solidity-utils/contracts/transparent-proxy/ProxyAdmin.sol';
import {TransparentUpgradeableProxy} from 'solidity-utils/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {IOwnable} from 'solidity-utils/contracts/transparent-proxy/interfaces/IOwnable.sol';
import {Collector} from '../../../periphery/contracts/treasury/Collector.sol';
import '../../interfaces/IMarketReportTypes.sol';

contract AaveV3TreasuryProcedure {
  struct TreasuryReport {
    address treasuryImplementation;
    address proxyAdmin;
    address treasury;
  }

  function _deployAaveV3Treasury(
    address poolAdmin,
    address deployedProxyAdmin,
    bytes32 collectorSalt
  ) internal returns (TreasuryReport memory) {
    TreasuryReport memory treasuryReport;
    bytes32 salt = collectorSalt;
    address treasuryOwner = poolAdmin;

    if (salt != '') {
      Collector treasuryImplementation = new Collector{salt: salt}();
      treasuryImplementation.initialize(address(0), 0);

      treasuryReport.treasuryImplementation = address(treasuryImplementation);

      if (deployedProxyAdmin == address(0)) {
        treasuryReport.proxyAdmin = address(new ProxyAdmin{salt: salt}());
        IOwnable(treasuryReport.proxyAdmin).transferOwnership(treasuryOwner);
      } else {
        treasuryReport.proxyAdmin = deployedProxyAdmin;
      }

      treasuryReport.treasury = address(
        new TransparentUpgradeableProxy{salt: salt}(
          treasuryReport.treasuryImplementation,
          treasuryReport.proxyAdmin,
          abi.encodeWithSelector(
            treasuryImplementation.initialize.selector,
            address(treasuryOwner),
            0
          )
        )
      );
    } else {
      Collector treasuryImplementation = new Collector();
      treasuryImplementation.initialize(address(0), 0);
      treasuryReport.treasuryImplementation = address(treasuryImplementation);

      if (deployedProxyAdmin == address(0)) {
        treasuryReport.proxyAdmin = address(new ProxyAdmin());
        IOwnable(treasuryReport.proxyAdmin).transferOwnership(treasuryOwner);
      } else {
        treasuryReport.proxyAdmin = deployedProxyAdmin;
      }

      treasuryReport.treasury = address(
        new TransparentUpgradeableProxy(
          treasuryReport.treasuryImplementation,
          treasuryReport.proxyAdmin,
          abi.encodeWithSelector(
            treasuryImplementation.initialize.selector,
            address(treasuryOwner),
            100_000
          )
        )
      );
    }

    return treasuryReport;
  }
}
