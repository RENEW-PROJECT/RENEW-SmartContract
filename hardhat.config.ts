import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "dotenv/config"
const deployPrivateKey = process.env.DEPLOY_PRIVATE_KEY as string;
const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      }
    }
  },
  networks: {
    mumbai: {
      url:  "https://rpc-mumbai.maticvigil.com",
      accounts:
          [deployPrivateKey],

    },
    polygon_mainnet: {
      url:  "https://rpc-mumbai.maticvigil.com",
      accounts: [deployPrivateKey],

    },
  }
};

export default {
  ...config,
  etherscan: {
    apiKey: 'XJE24DAHJ75A4G5381HIRE23RQ62W1G1IS',
  }
};