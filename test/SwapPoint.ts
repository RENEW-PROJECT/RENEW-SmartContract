import { expect } from "chai";
import { ethers } from "hardhat";

describe("Renew Swap Point Testing", () => {
    let renewTokSwapPoint: any;
    let owner: any;
    let user1: any;
    let user2: any;
    let token: any;
    const ratio = 100

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();

        const Token = await ethers.getContractFactory('RenewToken'); // Replace 'YourTokenContract' with the name of your token contract
        token = await Token.connect(owner).deploy('RENEW','RENEW',1000000000, 18, owner.address);

        const RenewTokSwapPoint = await ethers.getContractFactory('RenewTokSwapPoint');
        renewTokSwapPoint = await RenewTokSwapPoint.connect(owner).deploy(token.getAddress(), ratio);
    });

    it('should deploy with correct initial values', async function () {
        // expect(await renewTokSwapPoint.token()).to.equal(token.address);
        // expect(await renewTokSwapPoint.ratio()).to.equal(ratio);
        expect(await renewTokSwapPoint.owner()).to.equal(owner.address);
    });

    it('should whitelist user', async function () {
        await renewTokSwapPoint.setWhiteList(user1.address);
        expect(await renewTokSwapPoint.whitelist(user1.address)).to.equal(true);
    });

    it('should remove user from whitelist', async function () {
        await renewTokSwapPoint.setWhiteList(user1.address);
        expect(await renewTokSwapPoint.whitelist(user1.address)).to.equal(true);

        await renewTokSwapPoint.removeWhiteList(user1.address);
        expect(await renewTokSwapPoint.whitelist(user1.address)).to.equal(false);
    });

    it('should redeem points for user', async function () {
        const points = 100;
        const amount = points * ratio;
        const balanceOwner = await token.balanceOf(owner.address)
        await token.connect(owner).approve(renewTokSwapPoint, amount);
        await renewTokSwapPoint.connect(owner).redeemPoint(user1.address, points, 1);
        const user1Balance = await token.balanceOf(user1.address);
        expect(user1Balance).to.equal(amount);
    });

    it('should not redeem points for user if not whitelist', async function(){
        const points = 100;
        const amount = points * ratio;
        await token.connect(user1).approve(renewTokSwapPoint, amount);
        await expect(renewTokSwapPoint.connect(user1).redeemPoint(user2.address, points, 1)).to.be.reverted;
    });

    it('should configure new ratio by the owner', async function () {
        const newRatio = 200;

        await renewTokSwapPoint.connect(owner).configRatio(newRatio);
        expect(await renewTokSwapPoint.ratio()).to.equal(newRatio);
    });
    it('should not config new ratio if not owner', async function() {
        const newRatio = 200;
        await expect(renewTokSwapPoint.connect(user1).configRatio(newRatio)).to.be.reverted;
    })


})