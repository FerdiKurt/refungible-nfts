// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import './ARFNFT.sol';

contract RefungibleNFTTokens is ARFNFT {
    constructor(
        string memory _name,
        string memory _symbol,
        uint _nftId,
        address _nftAddress,
        address _stableCoinAddress,
        uint _nftSharePrice,
        uint _nftTotalShares
    ) ERC20(_name, _symbol) {
        owner = msg.sender;
        nft = IERC721Metadata(_nftAddress);
        stableCoin = IERC20(_stableCoinAddress);

        nftId = _nftId;
        nftSharePrice = _nftSharePrice;
        nftTotalShares = _nftTotalShares;

        require(nft.ownerOf(_nftId) == msg.sender, 'Sender must be NFT Token Owner!');
        require(nftSharePrice != 0, 'Price cannot be zero!');
        require(nftTotalShares >= 100, 'At least 100 shares required!');
    }

    function startSale(uint _nftId, uint _dayLimit) external override onlyOwner() {
        require(_dayLimit >= 7 && _dayLimit <=14, 'Invalid sale time provided!');

        nft.transferFrom(msg.sender, address(this), _nftId);
        
        nftRemaningShares = nftTotalShares;
        endOfSale = block.timestamp + (_dayLimit * 86400);

        emit SaleStarted(IERC721Metadata(nft).name(), _nftId, nftRemaningShares, _dayLimit);
    }

    function buyShare(uint _amountOfShare) external override {
        require(endOfSale > 0, 'Sale not started yet!');
        require(block.timestamp <= endOfSale, 'Sale is finished');
        require(_amountOfShare <= nftRemaningShares, 'Not enough shares left!');

        uint requiredAmount = _amountOfShare * nftSharePrice;
        stableCoin.transferFrom(msg.sender, address(this), requiredAmount);

        nftSoldedShares = nftSoldedShares + _amountOfShare;
        nftRemaningShares = nftRemaningShares  - _amountOfShare;
        
        _mint(msg.sender, _amountOfShare);

        emit ShareBought(
            msg.sender, 
            nftId, 
            _amountOfShare, 
            nftSoldedShares,
            nftRemaningShares 
        );
    }

    function withDrawFromContract() external override onlyOwner() {
        require(endOfSale < block.timestamp, 'Sale not finished yet!');
        require(isWithdrawed == false, 'Owner already withdrawed!');
        
        isWithdrawed = true;
        uint stableCoinBalance = stableCoin.balanceOf(address(this));
        if (nftSoldedShares > 0) {
            stableCoin.transfer(owner, stableCoinBalance);
        }
      
        uint unsoldShares = nftRemaningShares;
        if (unsoldShares > 0) {
            _mint(owner, unsoldShares);
        }

        emit Withdraw(msg.sender, nftSoldedShares, unsoldShares);
    }
}