# Renew Tok Smartcontract

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Before start
```shell
npm i
```
Config .env
```shell
cp .env.example.env .env
```
Fill all variable in env

```shell
DEPLOY_PRIVATE_KEY=

RENEW_SWAP_OWNER_ADDRESS=
RENEW_TOKEN_OWNER_ADDRESS=
RENEW_SWAP_RATIO=

RENEW_ADDRESS=
```
Deploy RenewSwapcoin
```shell
npx hardhat deploy --network <network> script/deployRenewSwapPoint.ts
```

Deploy RenewToken
```shell
npx hardhat deploy --network <network> script/deployRenewToken.ts
```
