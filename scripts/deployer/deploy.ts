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

  const STARKNET_NETWORK = DEFAULT_STARKNET_NETWORK;
    // hre.config.mocha.starknetNetwork || DEFAULT_STARKNET_NETWORK;

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
  console.log(l1Signer.address)
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


  const Message = await deployL1(
    NETWORK, "MessageENS", BLOCK_NUMBER, [
    L1_STARKNET_ADDRESS,
    ENS_ADDRESS,
    l1Signer.address,  
  ]);

  const tokenUri: any= {};
  console.log(BigInt(web3.utils.asciiToHex('object')))
  tokenUri.asset_namespace= parseFixed("122468482507636")
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
  const token_uri=[parseFixed("184555836509371486644019136839411173249852705485729074225653387927518275942"), parseFixed("181049748096098777417068739115489273933273585381715238407159336295106703204"), parseFixed("209332782685246350879226324629480826682111707209325714458032651979985071722"), 7565166]
  const token_uri2=[parseFixed("184555836509371486644019136839411173249852705485729074225653387927518275942"), parseFixed("210616560794178717850935920065495060911188822037429046327979330294206130042"), parseFixed("187985923959723853589968256655376306670773667376910287781628159691950468714"), 7565166]
 
  // const token_uri=stringToFeltArray("184555836509371486644019136839411173249852705485729074225653387927518275942,181049748096098777417068739115489273933273585381715238407159336295106703204,209332782685246350879226324629480826682111707209325714458032651979985071722,7565166")
  
  // console.log(...token_uri)
  // console.log(token_uri.length)
  // console.log(
  //   `STARKNET_NETWORK="alpha-goerli" starknet deploy --inputs ${l2Object.address} ${Message.address} ${token_uri.length} ${token_uri[0]} ${token_uri[1]} ${token_uri[2]} ${token_uri[3]} --contract starknet-artifacts/contracts/l2/Philand.cairo/Philand.json`
  // );

  const l2Material = await deployL2(
    STARKNET_NETWORK,
    "Material",
    BLOCK_NUMBER,
    {
      token_id : 1,
      token_uri : token_uri2
     
    }
  );

  const l2Login = await deployL2(
    STARKNET_NETWORK,
    "Login",
    BLOCK_NUMBER,
    {
     material_address : asDec(l2Material.address),
    }
  );
  const l2Craft = await deployL2(
    STARKNET_NETWORK,
    "Craft",
    BLOCK_NUMBER,
    {
     material_address : asDec(l2Material.address),
    }
  );
  const l2PHILAND = await deployL2(
    STARKNET_NETWORK,
    "Philand",
    BLOCK_NUMBER,
    {
     object_address : asDec(l2Object.address),
     l1_philand_address : asDec(Message.address),
    //  token_uri_len : 4,
     token_uri : token_uri,
    }
  );

  console.log(asDec(l2PHILAND.address))
  console.log(stringToFeltArray("zak3939.eth"))
  // await l2Signer.sendTransaction(deployer, l2PHILAND, "create_l2_object", [
  //   asDec(l2Object.address),
  //   [2,0],
  //   4,
  //   token_uri2,
  // ]);

}

export function printAddresses() {
  const NETWORK = hre.network.name;

  const contracts = [
    "account-deployer",
    "MessageENS",
    "Object",
    "Material",
    "Login",
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
  console.log(calldata)
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
  console.log(calldata)
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

/**
 * Converts a string into an array of numerical characters in utf-8 encoding
 * @param {string} str - The string to convert
 * @returns {bigint[]} - The string converted as an array of numerical characters
 */
 export function stringToFeltArray(str: string): bigint[] {
  const strArr = str.split(',');
  return strArr.map(char => BigInt(Buffer.from(char)[0].toString(10)));
}
