const hre = require("hardhat");

deployFakeLoot().catch((err) => console.log(err));


export async function deployFakeLoot() {
  const FakeLoot = await hre.ethers.getContractFactory("FakeLoot");
  const fakeloot = await FakeLoot.deploy();

  await fakeloot.deployed();

  console.log("Loot deployed to:", fakeloot.address);
  console.log(`npx hardhat verify --network goerli ${fakeloot.address}`)
}
