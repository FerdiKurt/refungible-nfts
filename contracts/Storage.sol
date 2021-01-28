// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import '@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

// contract for storage variables
contract Storage {
    address public owner;
    
    IERC721Metadata public nft;
    IERC20 public stableCoin;
    uint public nftId;
    
    uint public nftSharePrice;
    uint public nftTotalShares;
    uint public endOfSale;

    uint public nftSoldedShares;
    uint public nftRemaningShares;

    bool isWithdrawed;
}