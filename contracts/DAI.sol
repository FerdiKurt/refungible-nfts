// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract DAI is ERC20 {
    constructor() ERC20('DAI Stablecoin', 'DAI') {}

    function mint(address _to, uint _amount) external {
        _mint(_to, _amount);
    }
}