const { time } = require('@openzeppelin/test-helpers');
const RFT = artifacts.require('RFT.sol');
const NFT = artifacts.require('NFT.sol');
const DAI = artifacts.require('DAI.sol');

const DAI_AMOUNT = web3.utils.toWei('25000');
const SHARE_AMOUNT = web3.utils.toWei('25000');

contract('RFT', async addresses => {
  const [admin, buyer1, buyer2, _] = addresses;

  it('should work', async () => {
    //Deploy dai and nft tokens
    const dai = await DAI.new();
    const nft = await NFT.new('My awesome NFT', 'NFT');
    await nft.mint(admin, 123);
    await Promise.all([
      dai.mint(buyer1, DAI_AMOUNT),
      dai.mint(buyer2, DAI_AMOUNT),
    ]);

    // Deploy fungible NFT & start ICO
    const rft = await RFT.new(
      'My Awesome Fungible NFT',
      'FNFT',
      nft.address,
      dai.address,
      123,
      1,
      web3.utils.toWei('50000'),
    );
    await nft.approve(rft.address, 123);
    await rft.startSale();

    //Invest in ICO
    await dai.approve(rft.address, DAI_AMOUNT, {from: buyer1});  
    await rft.buyShare(SHARE_AMOUNT, {from: buyer1});
    await dai.approve(rft.address, DAI_AMOUNT, {from: buyer2});  
    await rft.buyShare(SHARE_AMOUNT, {from: buyer2});

    //End ICO
    await time.increase(7 * 86400 + 1); 
    await rft.withDrawFromContract();

    //Check balances
    const balanceShareBuyer1 = await rft.balanceOf(buyer1);
    const balanceShareBuyer2 = await rft.balanceOf(buyer2);
 
    assert(balanceShareBuyer1.toString() === SHARE_AMOUNT);
    assert(balanceShareBuyer2.toString() === SHARE_AMOUNT);

    const balanceAdminDAI = await dai.balanceOf(admin);
    assert(balanceAdminDAI.toString() === web3.utils.toWei('50000'));
  });
});