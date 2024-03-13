# RENEW-Smartcontract

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
$ npx hardhat deploy --network <network> script/deployRenewSwapPoint.ts
```

Deploy RenewToken
```shell
$ npx hardhat deploy --network <network> script/deployRenewToken.ts
```

Script batch Transfer

## Check folder interation, file renewToken.ts
### Update data in csv file
```shell
address,amount
0x223bE08282bd6B073Eff6552Efd69A3f6806e30D,1.9
```
### Running file renewToken.ts

```shell
$ ts-node interation/renewToken.ts
```
