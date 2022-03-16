
const hre = require("hardhat");


deployFakeLoot().catch((err) => console.log(err));

const GOERLI_ENS_ADDRESS="0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"

export async function deployFakeLoot() {

  const subdomainENS = await hre.ethers.getContractFactory("SubdomainENS");
  const subdomain = await subdomainENS.deploy(GOERLI_ENS_ADDRESS);

  await subdomain.deployed();

  console.log("test deployed to:", subdomain.address);
  console.log(`npx hardhat verify --network goerli ${subdomain.address} ${GOERLI_ENS_ADDRESS}`)
}