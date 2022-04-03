import { ethers } from "ethers";
import { task } from "hardhat/config";

task("setBalance", "Set balance of L1 address on fork")
  .addParam("balance", "Balance to set")
  .addOptionalParam("address", "Address to set balance of")
  .setAction(async ({ balance, address }, hre) => {
    const NETWORK = hre.network.name;
    console.log(`Calling on ${NETWORK}`);
    const mnemonic: string | undefined = process.env.MNEMONIC;
    if (!mnemonic) {
      throw new Error("Please set your MNEMONIC in a .env file");
    }
    const addressFromMnemonic =
      hre.ethers.Wallet.fromMnemonic(mnemonic).address;
    const _address = address || addressFromMnemonic;
    const balanceWei = hre.ethers.utils.parseEther(balance).toHexString();
    await hre.network.provider.request({
      method: "hardhat_setBalance",
      params: [_address, balanceWei.replace(/(?<=0x)0+/, "")],
    });
  });

const toBytes32 = (bn: ethers.BigNumber) => {
  return ethers.utils.hexlify(ethers.utils.zeroPad(bn.toHexString(), 32));
};


