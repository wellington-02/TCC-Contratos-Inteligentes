// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ATokenInstance} from 'aave-v3-core/instances/ATokenInstance.sol';
import {VariableDebtTokenInstance} from 'aave-v3-core/instances/VariableDebtTokenInstance.sol';
import {StableDebtTokenInstance} from 'aave-v3-core/instances/StableDebtTokenInstance.sol';
import {IPool} from 'aave-v3-core/contracts/interfaces/IPool.sol';
import {IAaveIncentivesController} from 'aave-v3-core/contracts/interfaces/IAaveIncentivesController.sol';

contract AaveV3TokensProcedure {
  struct TokensReport {
    address aToken;
    address variableDebtToken;
    address stableDebtToken;
  }

  function _deployAaveV3TokensImplementations(
    address poolProxy
  ) internal returns (TokensReport memory) {
    TokensReport memory tokensReport;
    bytes memory empty;

    ATokenInstance aToken = new ATokenInstance(IPool(poolProxy));
    VariableDebtTokenInstance variableDebtToken = new VariableDebtTokenInstance(IPool(poolProxy));
    StableDebtTokenInstance stableDebtToken = new StableDebtTokenInstance(IPool(poolProxy));

    aToken.initialize(
      IPool(poolProxy), // pool proxy
      address(0), // treasury
      address(0), // asset
      IAaveIncentivesController(address(0)), // incentives controller
      0, // decimals
      'ATOKEN_IMPL', // name
      'ATOKEN_IMPL', // symbol
      empty // params
    );

    variableDebtToken.initialize(
      IPool(poolProxy), // initializingPool
      address(0), // underlyingAsset
      IAaveIncentivesController(address(0)), // incentivesController
      0, // debtTokenDecimals
      'VARIABLE_DEBT_TOKEN_IMPL', // debtTokenName
      'VARIABLE_DEBT_TOKEN_IMPL', // debtTokenSymbol
      empty // params
    );

    stableDebtToken.initialize(
      IPool(poolProxy), // initializingPool
      address(0), // underlyingAsset
      IAaveIncentivesController(address(0)), // incentivesController
      0, // debtTokenDecimals
      'STABLE_DEBT_TOKEN_IMPL', // debtTokenName
      'STABLE_DEBT_TOKEN_IMPL', // debtTokenSymbol
      empty // params
    );

    tokensReport.aToken = address(aToken);
    tokensReport.variableDebtToken = address(variableDebtToken);
    tokensReport.stableDebtToken = address(stableDebtToken);

    return tokensReport;
  }
}
