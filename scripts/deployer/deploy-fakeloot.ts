
const hre = require("hardhat");


deployFakeLoot().catch((err) => console.log(err));

const GOERLI_L1_STARKNET_ADDRESS= "0xde29d060D45901Fb19ED6C6e959EB22d8626708e"

export async function deployFakeLoot() {
  // const FakeLoot = await hre.ethers.getContractFactory("FakeLoot");
  // const fakeloot = await FakeLoot.deploy();

  // await fakeloot.deployed();

  // console.log("Loot deployed to:", fakeloot.address);
  // console.log(`npx hardhat verify --network goerli ${fakeloot.address}`)

  const L1L2Example = await hre.ethers.getContractFactory("L1L2Example");
  const faketest = await L1L2Example.deploy(GOERLI_L1_STARKNET_ADDRESS);

  await faketest.deployed();

  console.log("test deployed to:", faketest.address);
  console.log(`npx hardhat verify --network goerli ${faketest.address} ${GOERLI_L1_STARKNET_ADDRESS}`)
}