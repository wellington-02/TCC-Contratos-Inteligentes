// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import { ISSROracle } from 'src/interfaces/ISSRAuthOracle.sol';

interface IOracleReceiver {
    function setSUSDSData(ISSROracle.SUSDSData calldata data) external;
}
