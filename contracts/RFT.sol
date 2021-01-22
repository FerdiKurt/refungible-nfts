// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract RFT is ERC20 {
    uint public nftSharePrice;
    uint public nftTotalShares;
    uint public endOfSale;

    uint public nftId;
    IERC721 public nft;
    IERC20 public dai;

    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner, 'Only owner!');
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _nftAddress,
        address _daiAddress,
        uint _nftId,
        uint _nftSharePrice,
        uint _nftTotalShares
    ) ERC20(_name, _symbol) {
        owner = msg.sender;
        nft = IERC721(_nftAddress);
        dai = IERC20(_daiAddress);
        nftId = _nftId;
        nftSharePrice = _nftSharePrice;
        nftTotalShares = _nftTotalShares;
    }

    function startSale() external onlyOwner() {
        nft.transferFrom(msg.sender, address(this), nftId);
        endOfSale = block.timestamp + 7 * 86400;
    }

    function buyShare(uint _amountOfShare) external {
        require(endOfSale > 0, 'Sale not started yet!');
        require(block.timestamp <= endOfSale, 'Sale is finished');
        require(totalSupply() + _amountOfShare <= nftTotalShares, 'Not enough shares left!');

        uint requiredDaiAmount = _amountOfShare * nftSharePrice;
        dai.transferFrom(msg.sender, address(this), requiredDaiAmount);

        _mint(msg.sender, _amountOfShare);
    }

    function withDrawFromContract() external onlyOwner() {
        require(endOfSale < block.timestamp, 'Sale not finished yet!');

        uint daiBalanceInContract = dai.balanceOf(address(this));
        if (daiBalanceInContract > 0) {
            dai.transfer(owner, daiBalanceInContract);
        }

        uint unsoldShares = nftTotalShares - totalSupply();
        if (unsoldShares > 0) {
            _mint(owner, unsoldShares);
        }
    }
}