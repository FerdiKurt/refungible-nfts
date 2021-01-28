const { time, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');

const RFT = artifacts.require('RefungibleNFTTokens.sol');
const NFT = artifacts.require('NFT.sol');
const Stablecoin = artifacts.require('Stablecoin.sol');

function toBN(arg) {
    return web3.utils.toBN(arg)
}

function toWEI(arg) {
    return web3.utils.toWei(arg)
}

contract('Refungible Art Tokens', accounts => {
    let rft
    let stableCoin
    let nft

    const [nftOwner, buyer1, buyer2, _] = accounts;
    const STABLE_COIN_AMOUNT = 200
    const TOTAL_SHARE = 275
    const NFT_ID = 1907
    const DAY_LIMIT = 10
  
    before(async () => {
        stableCoin = await Stablecoin.new('DAI Stablecoin', 'DAI')
        nft = await NFT.new('ART Tokens', 'AT')

        await nft.mint(nftOwner, NFT_ID)
        await Promise.all([
            stableCoin.mint(buyer1, STABLE_COIN_AMOUNT),
            stableCoin.mint(buyer2, STABLE_COIN_AMOUNT),
        ]);

        rft = await RFT.new(
            'Refungible Art Tokens', 
            'RFAT',
            NFT_ID,
            nft.address,
            stableCoin.address,
            toBN(1),
            TOTAL_SHARE
        )

        await nft.approve(rft.address, NFT_ID, { from: nftOwner })
        await stableCoin.approve(rft.address, 150, {from: buyer1});  
        await stableCoin.approve(rft.address, 150, {from: buyer2});  
    })
    
    // sale start by nft owner
    it('should NOT buy share if sale not started', async () => {
        await expectRevert(
            rft.buyShare(
                STABLE_COIN_AMOUNT,
                { from: buyer1 }
            ),
            'Sale not started yet!'
        )
    })
    it('should NOT start sale if not owner', async () => {
        await expectRevert(
            rft.startSale(
                NFT_ID,
                DAY_LIMIT,
                { from: buyer1 }
            ),
            'Only owner!'
        )
    })
    it('should NOT start sale, time limit is between 7 to 14 days', async () => {
        await expectRevert(
            rft.startSale(
                NFT_ID,
                5,
                { from: nftOwner }
            ),
            'Invalid sale time provided!'
        )       
    })
    it('should START sale', async () => {
        const tx = await rft.startSale(
            NFT_ID,
            DAY_LIMIT,
            { from: nftOwner }
        )

        const tokenOwner = nft.ownerOf(NFT_ID)
        assert(tokenOwner, rft.address)

        await expectEvent(tx, 'SaleStarted', {
            nftName: 'ART Tokens',
            nftId: NFT_ID.toString(),
            nftRemaningShares: TOTAL_SHARE.toString(),
            dayLimit: DAY_LIMIT.toString()
        })
    })
    
    // buy nft share
    it('should BUY share', async () => {
        const tx1 = await rft.buyShare(150, { from: buyer1 })
        const tx2 = await rft.buyShare(100, { from: buyer2 })

        await expectEvent(tx1, 'ShareBought', {
            buyer: buyer1,
            nftId: NFT_ID.toString(),
            amountOfShare: '150',
            soldedShares: '150', 
            remainingShares: '125'
        })

        await expectEvent(tx2, 'ShareBought', {
            buyer: buyer2,
            nftId: NFT_ID.toString(),
            amountOfShare: '100',
            soldedShares: '250', 
            remainingShares: '25'
        })
    })

    it('should NOT withdraw from contract if sale not finished', async () => {
        await expectRevert(
            rft.withDrawFromContract({ from: nftOwner }),
            'Sale not finished yet!'
        )
    })

    it('should NOT buy share if not enough shares left', async () => {
        await expectRevert(
            rft.buyShare(50, { from: buyer2 }),
            'Not enough shares left!'
        )
    })
    it('should NOT buy share if sale is finished', async () => {
        await time.increase(DAY_LIMIT * 86400 + 1)

        await expectRevert(
            rft.buyShare(10, { from: buyer2 }),
            'Sale is finished'
        )
    })
    
    // withdraw assets and coins from contract
    it('should NOT withdraw from contract if not owner', async () => {
        await expectRevert(
            rft.withDrawFromContract({ from: buyer1 }),
            'Only owner!'
        )
    })
    it('should WITHDRAW from contract', async () => {
        const tx = await rft.withDrawFromContract({ from: nftOwner })
        const balanceShareBuyer1 = await rft.balanceOf(buyer1);
        const balanceShareBuyer2 = await rft.balanceOf(buyer2);

        assert(balanceShareBuyer1.toString() === '150');
        assert(balanceShareBuyer2.toString() === '100');
   
        const ownerStableCoinBalance = await stableCoin.balanceOf(nftOwner)
        const ownerNftShareBalance = await rft.balanceOf(nftOwner)
        
        assert.equal(ownerStableCoinBalance.toString(), '250')
        assert.equal(ownerNftShareBalance.toString(), '25')
  

        await expectEvent(tx, 'Withdraw', {
            owner: nftOwner,
            soldedShares: '250',
            remainingShares: '25'
        })
    })
    it('should NOT withdraw from contract if already withdrawed', async () => {
        await expectRevert(
            rft.withDrawFromContract({ from: nftOwner }),
            'Owner already withdrawed!'
        )
    })
})