/**
 * Full goerli deploy including any permissions that need to be set.
 */
import { parseFixed } from "@ethersproject/bignumber";
import {
  getRequiredEnv,
} from "@makerdao/hardhat-utils";
import {
  // CHECK_STATUS_TIMEOUT,
  DEFAULT_STARKNET_NETWORK,
} from "@shardlabs/starknet-hardhat-plugin/dist/constants";
import { StarknetContract } from "@shardlabs/starknet-hardhat-plugin/dist/types";
import { writeFileSync } from "fs";
import hre from "hardhat";
import { isEmpty } from "lodash";
import { ec, KeyPair } from "starknet";
import web3 from "web3";
const { genKeyPair, getStarkKey } = ec;

import { getAddress, save, Signer } from "../utils";

async function genAndSaveKeyPair(): Promise<KeyPair> {
  const keyPair:any = genKeyPair();
  writeFileSync(
    ".env.deployer",
    `DEPLOYER_ECDSA_PRIVATE_KEY=${keyPair.priv.toString()}`
  );
  return keyPair;
}

export async function deployDeployer() {
  

  
  const NETWORK = hre.network.name;

  const STARKNET_NETWORK =
    hre.config.mocha.starknetNetwork || DEFAULT_STARKNET_NETWORK;

  const [l1Signer] = await hre.ethers.getSigners();

  // @ts-ignore
  const BLOCK_NUMBER = await l1Signer.provider.getBlockNumber();

  console.log(`Deploying deployer on ${NETWORK}/${STARKNET_NETWORK}`);

  const keyPair:any = await genAndSaveKeyPair();
  const publicKey = BigInt(getStarkKey(keyPair));

  const deployer = await deployL2(
    STARKNET_NETWORK,
    "Account",
    BLOCK_NUMBER,
    { _public_key: publicKey },
    "account-deployer"
  );

  writeFileSync(
    "deployer-key.json",
    JSON.stringify({ priv: keyPair.priv.toString() })
  );

  console.log(
    `Deployer private key is in deployer-key.json. It should be added to .env under DEPLOYER_ECDSA_PRIVATE_KEY`
  );

  // console.log(`Next steps:`);
  // console.log(`If You want to deploy object contract now:`);
  // console.log(
  //   `STARKNET_NETWORK=${STARKNET_NETWORK} starknet deploy --inputs ${asset_namespace} ${asset_reference} ${TOKENID} --contract starknet-artifacts/contracts/l2/Object.cairo/Object.json --salt <insert salt here>`
  // );
  // console.log(
  //   `After manual deployment object contract address should be added to .env:`
  // );
  // console.log(`${STARKNET_NETWORK.toUpperCase()}_L2_OBJECT_ADDRESS=...`);

  // console.log(
  //   `To verify object: npx hardhat starknet-verify --starknet-network ${STARKNET_NETWORK} --path contracts/l2/Object.cairo --address <L2_OBJECT_ADDRESS>`
  // );

  // console.log(
  //   "To find salt that will result in dai address staring with 'da1' prefix:"
  // );
  // console.log(`./scripts/vanity.py --ward ${deployer.address}`);
}

export async function deployBridge(): Promise<void> {
  const [l1Signer] = await hre.ethers.getSigners();

  let NETWORK;
  if (hre.network.name === "fork") {
    NETWORK = "mainnet";
  } else {
    NETWORK = hre.network.name;
  }
  const STARKNET_NETWORK = hre.starknet.network || DEFAULT_STARKNET_NETWORK;

  const ENS_ADDRESS = getRequiredEnv(
    `${NETWORK.toUpperCase()}_ENS_ADDRESS`
  );
  const L1_STARKNET_ADDRESS = getRequiredEnv(
    `${NETWORK.toUpperCase()}_L1_STARKNET_ADDRESS`
  );

  // @ts-ignore
  const BLOCK_NUMBER = await l1Signer.provider.getBlockNumber();

  console.log(`Deploying bridge on ${NETWORK}/${STARKNET_NETWORK}`);

  const DEPLOYER_KEY = getRequiredEnv(`DEPLOYER_ECDSA_PRIVATE_KEY`);
  const l2Signer = new Signer(DEPLOYER_KEY);

  const deployer = await getL2ContractAt(
    "Account",
    getAddress("account-deployer", NETWORK)
  );

  console.log(`Deploying from:`);
  console.log(`\tl1: ${(await l1Signer.getAddress()).toString()}`);
  console.log(`\tl2: ${deployer.address.toString()}`);

  const l1PHILAND = await deployL1(
    NETWORK, "PhilandL1", BLOCK_NUMBER, [
    L1_STARKNET_ADDRESS,
    ENS_ADDRESS,
  ]);

  // const asset_namespace =  BigInt(web3.utils.asciiToHex('object')).toString(10)
  // const asset_reference = "0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599"
  // const TokenId =  BigInt(web3.utils.asciiToHex('{id}')).toString(10)
  // const TokenUri =[
  //   BigInt(web3.utils.asciiToHex('object')).toString(10),
  //   "0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599",
  //   BigInt(web3.utils.asciiToHex('{id}')).toString(10)]
//   interface TokenUri {
//   [name: string]:any;
// } 
  const tokenUri: any= {};
  console.log(BigInt(web3.utils.asciiToHex('object')))
  tokenUri.asset_namespace= parseFixed("122468482507636")
  console.log(BigInt(web3.utils.asciiToHex('object')))
  // tokenUri.asset_reference= "0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599"
  console.log(BigInt(web3.utils.asciiToHex('philand')))
  tokenUri.asset_reference=parseFixed("1639999390772836")
  console.log(BigInt(web3.utils.asciiToHex("{id}")))
  tokenUri.token_id=parseFixed("2070504573")
  console.log(tokenUri)
  const l2Object:StarknetContract = await deployL2(
    STARKNET_NETWORK,
    "Object",
    BLOCK_NUMBER,
    {
     uri_:tokenUri
    }
  );
  
  const l2PHILAND = await deployL2(
    STARKNET_NETWORK,
    "Philand",
    BLOCK_NUMBER,
    {
     object :asDec(l2Object.address),
     l1_message :asDec(l1PHILAND.address)
    }
  );

  

}

export function printAddresses() {
  const NETWORK = hre.network.name;

  const contracts = [
    "account-deployer",
    "PhilandL1",
    "Object",
    "Philand",
  ];

  const addresses = contracts.reduce(
    (a, c) => Object.assign(a, { [c]: getAddress(c, NETWORK) }),
    {}
  );

  console.log(addresses);
}

async function wards(authable: StarknetContract, ward: StarknetContract) {
  return (await authable.call("wards", { user: asDec(ward.address) })).res;
}

function asDec(address: string): string {
  return BigInt(address).toString();
}

async function getL2ContractAt(name: string, address: string) {
  console.log(`Using existing contract: ${name} at: ${address}`);
  const contractFactory = await hre.starknet.getContractFactory(name);
  return contractFactory.getContractAt(address);
}

async function deployL2(
  network: string,
  name: string,
  blockNumber: number,
  calldata: any = {},
  saveName?: string
) {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  // CHECK_STATUS_TIMEOUT = 5000;
// 
  console.log(`Deploying: ${name}${(saveName && "/" + saveName) || ""}...`);
  const contractFactory = await hre.starknet.getContractFactory(name);

  const contract = await contractFactory.deploy(calldata);
  save(saveName || name, contract, hre.network.name, blockNumber);

  console.log(`Deployed: ${saveName || name} to: ${contract.address}`);
  console.log(
    `To verify: npx hardhat starknet-verify --starknet-network ${network} --path contracts/l2/${name}.cairo --address ${contract.address}`
  );
  return contract;
}

async function deployL1(
  network: string,
  name: string,
  blockNumber: number,
  calldata: any = [],
  saveName?: string
) {
  console.log(`Deploying: ${name}${(saveName && "/" + saveName) || ""}...`);
  const contractFactory = await hre.ethers.getContractFactory(name);
  console.log(...calldata)
  const contract = await contractFactory.deploy(...calldata);
  save(saveName || name, contract, hre.network.name, blockNumber);

  console.log(`Waiting for deployment to complete`);
  await contract.deployTransaction.wait();

  console.log(`Deployed: ${saveName || name} to: ${contract.address}`);
  console.log(
    `To verify: npx hardhat verify --network ${network} ${
      contract.address
    } ${calldata.filter((a: any) => !isEmpty(a)).join(" ")}`
  );
  await contract.deployed();
  return contract;
}
