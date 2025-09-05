// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

contract SUSDSMock {

    uint256 public ssr;
    uint256 public chi;
    uint256 public rho;

    constructor() {
        ssr = 1e27;
        chi = 1e27;
        rho = block.timestamp;
    }

    function setSSR(uint256 _ssr) external {
        ssr = _ssr;
    }

    function setChi(uint256 _chi) external {
        chi = _chi;
    }

    function setRho(uint256 _rho) external {
        rho = _rho;
    }

}
