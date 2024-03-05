import { ethers } from "hardhat";
import "dotenv/config"
async function main() {
    const name = 'RENEW'
    const symbol = 'RENEW'
    const initialSupply = '1000000000'
    const decimals = 18
    const owner = process.env.RENEW_TOKEN_OWNER_ADDRESS as string


    const token = await ethers.deployContract("RenewToken",
        [name, symbol, initialSupply, decimals, owner], {});

    await token.waitForDeployment();

    console.log(`Smartcontract Renew Token deployed to ${token.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
console.error(error);
process.exitCode = 1;
});
