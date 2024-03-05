import { ethers } from "hardhat";
import "dotenv/config"
async function main() {
  const tokenAddress = process.env.RENEW_ADDRESS as string
  const owner = process.env.RENEW_SWAP_OWNER_ADDRESS as string
  const ratio = ethers.parseUnits(process.env.RENEW_SWAP_RATIO as string, 18)
  console.log(tokenAddress, ratio, owner)


  const swapPoint = await ethers.deployContract("RenewTokSwapPoint",
      [tokenAddress, ratio, owner], {});

  await swapPoint.waitForDeployment();

  console.log(`Smartcontract RenewTokSwapPoint deployed to ${swapPoint.target}`);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
