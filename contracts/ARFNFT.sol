// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './Storage.sol';

// abstract contract for "Refungible Non Fungible Token"
abstract contract ARFNFT is ERC20, Storage {
    // functions to be implemented
    function startSale(uint _nftId, uint _dayLimit) external virtual;
    function buyShare(uint _amountOfShare) external virtual;
    function withDrawFromContract() external virtual;

    // events
    event SaleStarted(
        string nftName, 
        uint nftId, 
        uint nftRemaningShares, 
        uint dayLimit
    );
    event ShareBought(
        address buyer, 
        uint nftId,
        uint amountOfShare, 
        uint soldedShares, 
        uint remainingShares
    );
    event Withdraw(
        address owner, 
        uint soldedShares, 
        uint remainingShares
    );

    // modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner!');
        _;
    }
}

