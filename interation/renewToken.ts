import { ethers, Contract, Wallet } from "ethers";
import {abi} from './RenewToken.json'
import * as fs from 'fs';
import csvParser from 'csv-parser';


const contractAddress = '0x956641CDd05e0956C18ab6B07c48b6921Bb6c307' // replace real address

const providerURL = 'https://polygon-mumbai-pokt.nodies.app/' // replace with real chain RPC URL
const provider = new ethers.providers.JsonRpcProvider(providerURL)
const privateKey = '430a55b479363317675accb443822cc1c749aecfb215ae44873fe88a9449737f'  // replace with real private key
const wallet = new Wallet(privateKey, provider)
const contract = new Contract(contractAddress, abi, wallet)

const BatchTransferFromCSV = async () => {
    const addresses: any[] = []
    const values: any[] = []
    fs.createReadStream('interation/data.csv')
        .pipe(csvParser())
        .on('data', (data: any) => {
            const valueWei = ethers.utils.parseEther(data.amount)
            addresses.push(data.address);
            values.push(valueWei);
        })
        .on('end', async () => {
            // Now you can use the addresses and values arrays
            console.log('CSV import complete');
            console.log('Addresses:', addresses);
            console.log('Values:', values);
            await doBatchTransfer(addresses, values)
        });
};
const doBatchTransfer = async (wallet: string[], value: bigint[]) => {
    const result = await contract.batchTransfer(wallet, value);
    console.log(result)
}

BatchTransferFromCSV()