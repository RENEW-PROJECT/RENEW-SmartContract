import { expect } from "chai";
import { ethers } from "hardhat";

describe("Renew Token Testing", () => {
    let renewToken: any;
    let owner: any;
    let user1: any;
    let user2: any;
    let amount: any

    beforeEach(async () => {
        [owner, user1, user2] = await ethers.getSigners();
        const RenewToken = await ethers.getContractFactory('RenewToken');
        renewToken = await RenewToken.connect(owner).deploy(
            'RENEW','RENEW',1000000000, 18, owner.address);
        amount = ethers.parseUnits('10', 18);
        await renewToken.connect(owner).transfer(user1.address, amount);
        await renewToken.connect(owner).transfer(user2.address, amount);
    })

    it('should lock token by admin', async ()=> {
        // Lock Token
        await renewToken.connect(owner).lockTokens(user1.address, amount);
        await expect(renewToken.connect(user1).transfer(owner.address, amount)).to.be.revertedWith('Transfer amount exceeds unlocked balance');
    })
    it('should not lock if not admin', async ()=>{
        it('should not lock if not admin', async ()=> {
            await expect(renewToken.connect(user1).lockTokens(user2.address, amount)).to.be.reverted;
        });

    })
    it('should batch transfer', async ()=> {
        const batchAmount = ethers.parseUnits('2', 18)
        await renewToken.connect(owner).batchTransfer([user1.address, user2.address], [batchAmount, batchAmount])

    })


})

