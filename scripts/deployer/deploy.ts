/**
 * Full goerli deploy including any permissions that need to be set.
 */
import { getRequiredEnv } from "@makerdao/hardhat-utils";
import {
  // CHECK_STATUS_TIMEOUT,
  DEFAULT_STARKNET_NETWORK,
} from "@shardlabs/starknet-hardhat-plugin/dist/constants";
import { StarknetContract } from "@shardlabs/starknet-hardhat-plugin/dist/types";
import { writeFileSync } from "fs";
import hre from "hardhat";
import { isEmpty } from "lodash";
import { ec, KeyPair } from "starknet";
const { genKeyPair, getStarkKey } = ec;

import { getAddress, save, Signer } from "../utils";

async function genAndSaveKeyPair(): Promise<KeyPair> {
  const keyPair: any = genKeyPair();
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

  const keyPair: any = await genAndSaveKeyPair();
  const publicKey = BigInt(getStarkKey(keyPair));
  // const publicKey = getStarkKey(keyPair);
  const deployer = await deployL2(
    STARKNET_NETWORK,
    "Account",
    BLOCK_NUMBER,
    { public_key: publicKey },
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

  const ENS_ADDRESS = getRequiredEnv(`${NETWORK.toUpperCase()}_ENS_ADDRESS`);
  const L1_STARKNET_ADDRESS = getRequiredEnv(
    `${NETWORK.toUpperCase()}_L1_STARKNET_ADDRESS`
  );

  const XOROSHIRO_ADDRESS = getRequiredEnv(
    `${NETWORK.toUpperCase()}_XOROSHIRO_ADDRESS`
  );
  // @ts-ignore
  const BLOCK_NUMBER = await l1Signer.provider.getBlockNumber();
  console.log(l1Signer.address);
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

  const Message = await deployL1(NETWORK, "MessageENS", BLOCK_NUMBER, [
    L1_STARKNET_ADDRESS,
    ENS_ADDRESS,
    l1Signer.address,
  ]);

  // const l2ERC20: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "ERC20_Mintable",
  //   BLOCK_NUMBER,
  //   {
  //     // name: ("Meta Mintable Token"), symbol: "phi"
  //     name: parseFixed("1725995323023367784961866765022190509016966510"),
  //     symbol: parseFixed("5066068"),
  //     decimals: 18,
  //     initial_supply: { low: 500, high: 0 },
  //     recipient: asDec(deployer.address),
  //     owner: asDec(deployer.address),
  //   }
  // );

  // const l2PrimitiveMaterial: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "PrimitiveMaterial",
  //   BLOCK_NUMBER,
  //   {
  //     owner: asDec(deployer.address),
  //   }
  // );

  // const l2CraftedMaterial: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "CraftedMaterial",
  //   BLOCK_NUMBER,
  //   {
  //     owner: asDec(deployer.address),
  //   }
  // );
  // const l2WrapPrimitiveMaterial: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "WrapPrimitiveMaterial",
  //   BLOCK_NUMBER,
  //   {
  //     owner: asDec(deployer.address),
  //   }
  // );
  // const l2WrapCraftedMaterial: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "WrapCraftedMaterial",
  //   BLOCK_NUMBER,
  //   {
  //     owner: asDec(deployer.address),
  //   }
  // );

  // const l2Wrap: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "Wrap",
  //   BLOCK_NUMBER,
  //   {
  //     primitive_material_address: asDec(l2PrimitiveMaterial.address),
  //     crafted_material_address: asDec(l2CraftedMaterial.address),
  //     wrap_primitive_material_address: asDec(l2WrapPrimitiveMaterial.address),
  //     wrap_crafted_material_address: asDec(l2WrapCraftedMaterial.address),
  //   }
  // );

  const l2Object: StarknetContract = await deployL2(
    STARKNET_NETWORK,
    "PhiObject",
    BLOCK_NUMBER,
    {
      owner: asDec(deployer.address),
    }
  );

  // const l2DailyBonus: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "DailyBonus",
  //   BLOCK_NUMBER,
  //   {
  //     IXoroshiro_address: asDec(XOROSHIRO_ADDRESS),
  //     primitive_material_address: asDec(l2PrimitiveMaterial.address),
  //     erc20Address: asDec(l2ERC20.address),
  //     treasury_address: asDec(deployer.address),
  //   }
  // );
  // const l2Craft: StarknetContract = await deployL2(
  //   STARKNET_NETWORK,
  //   "Craft",
  //   BLOCK_NUMBER,
  //   {
  //     primitive_material_address: asDec(l2PrimitiveMaterial.address),
  //     crafted_material_address: asDec(l2CraftedMaterial.address),
  //   }
  // );
  // const l2PHILAND = await deployL2(STARKNET_NETWORK, "Philand", BLOCK_NUMBER, {
  //   object_address: asDec(l2Object.address),
  //   l1_philand_address: asDec(Message.address),
  //   // //  token_uri_len : 4,
  //   //  token_uri : token_uri,
  // });
    const l2PHI = await deployL2(STARKNET_NETWORK, "Phi", BLOCK_NUMBER, {
    object_address: asDec(l2Object.address),
    l1_philand_address: asDec(Message.address),
    // //  token_uri_len : 4,
    //  token_uri : token_uri,
  });
}

export function printAddresses() {
  const NETWORK = hre.network.name;

  const contracts = [
    "account-deployer",
    "MessageENS",
    // "ERC20_Mintable",
    // "CraftedMaterial",
    // "PrimitiveMaterial",
    // "WrapPrimitiveMaterial",
    // "WrapCraftedMaterial",
    "PhiObject",
    // "Craft",
    // "DailyBonus",
    // "Wrap",
    // "Philand",
    "Phi"
  ];

  const addresses = contracts.reduce(
    (a, c) => Object.assign(a, { [c]: getAddress(c, NETWORK) }),
    {}
  );

  console.log(addresses);
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
  console.log(calldata);
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
  console.log(calldata);
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
  const strArr = str.split(",");
  return strArr.map((char) => BigInt(Buffer.from(char)[0].toString(10)));
}
