// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Stablecoin is ERC20 {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {}

    function mint(address _to, uint _amount) external {
        _mint(_to, _amount);
    }
}