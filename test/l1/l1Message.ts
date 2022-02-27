import { smock } from "@defi-wonderland/smock";
import { parseFixed } from "@ethersproject/bignumber";
import {
  simpleDeploy
} from "@makerdao/hardhat-utils";
import chai, { expect } from "chai";
import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import web3 from "web3";
const { ethers } = require("hardhat");
const {
  keccak256,
  toBuffer,
  ecsign,
  bufferToHex,
} = require("ethereumjs-utils");
const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

require('dotenv').config()
chai.use(smock.matchers);

const createGrid = parseFixed(
  "230744737155971716570284140634551213064188756564393274009046094202533668423"
);

const claimL1Object = parseFixed(
  "1426524085905910661260502794228018787518743932072178038305015687841949115798"
);

const claimL2Object = parseFixed(
  "725729645710710348624275617047258825327720453914706103365608274738200251740"
);

// str_to_felt('zak3939.eth')=147948997034476692113290344
  const ENSLABEL =web3.utils.asciiToHex('zak3939.eth')
  const ENSNAME= BigInt(ENSLABEL).toString(10)

  beforeEach("checkens", function () {
    it("checkens", async () => {
      const { admin,l1Alice,ens,resolver,ethregistrar } =
        await setupTest();
        await ethregistrar.addController(admin.address);
        await ens.setSubnodeOwner(namehash.hash(""), sha3('eth'), ethregistrar.address);
        await ethregistrar.register(sha3('test'), l1Alice.address, 86400);
        await resolver.setAddr(namehash.hash('test.eth'), l1Alice.address)

        expect(await resolver.addr(namehash.hash('test.eth'))).to.equal(l1Alice.address);
    });
    
});
    
      
    
  describe("createPhiland", function () {
    it("sends a message to l2, emits event", async () => {
      const { admin,l1Alice, starkNetFake, l1Philand, l2PhilandAddress,ens,resolver,ethregistrar } =
        await setupTest();
      await ethregistrar.addController(admin.address);
      await ens.setSubnodeOwner(namehash.hash(""), sha3('eth'), ethregistrar.address);
      await ethregistrar.register(sha3('zak3939'), l1Alice.address, 86400);
      await resolver.setAddr(namehash.hash('zak3939.eth'), l1Alice.address)
      const ENSLABEL = web3.utils.asciiToHex('zak3939.eth')
      const ENSNAME= BigInt(ENSLABEL).toString(10)


      await expect(l1Philand.connect(l1Alice).createPhiland(l2PhilandAddress, ENSNAME))
        .to.emit(l1Philand, "LogCreatePhiland")
        .withArgs(l1Alice.address, ENSNAME);

      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        createGrid,
        [ENSNAME]
      );
    });
    
});

describe("claimL1NFT", function () {
    it("sends a message to l2, claim nft event", async () => {
      const { l1Alice, starkNetFake, l1Philand, l2PhilandAddress } =
        await setupTest();
  
      const lootContract = "0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7"
      const tokenid = 13
      await expect(l1Philand.connect(l1Alice).claimL1Object(l2PhilandAddress, ENSNAME,lootContract,tokenid))
        .to.emit(l1Philand, "LogClaimL1NFT")
        .withArgs(ENSNAME,lootContract,tokenid);

      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        claimL1Object,
        [ENSNAME,lootContract,tokenid]
      );
    });
});

describe("claiml2Object", function () {
    it("sends a message to l2, claim nft event", async () => {
      const { l1Alice, starkNetFake, l1Philand, l2PhilandAddress,coupons } =
        await setupTest();
  
      const ObjectContract = "0x03a83e4e8b1a6e413d15ea5ee5bcd5bb2b2439f341010c3740fd7e51b2e14b64"
      const tokenid = 13
      console.log(coupons[l1Alice.address]["coupon"])
      await expect(l1Philand.connect(l1Alice).claimL2Object(l2PhilandAddress, ENSNAME,ObjectContract,tokenid,coupons[l1Alice.address]["coupon"]))
        .to.emit(l1Philand, "LogClaimL2Object")
        .withArgs(ENSNAME,ObjectContract,tokenid);
      console.log("finish")
      
      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        claimL2Object,
        [ENSNAME,ObjectContract,tokenid]
      );
    });
});




async function setupTest() {
  const [admin, l1Alice, l1Bob] = await hre.ethers.getSigners();

  const starkNetFake = await smock.fake("IStarknetCore");
  const L2_PHILAND_ADDRESS = 31415;
  
  const ens = await simpleDeploy("ENSRegistry",[]);
  const resolver = await simpleDeploy("TestResolver",[]);
  const ethregistrar= await simpleDeploy("TestRegistrar",[ens.address,
      namehash.hash('eth'),]);

  const coupons = getCoupon(l1Alice.address)
  const l1philand = await simpleDeploy("PhilandL1", [
    starkNetFake.address,
    // ens.address,
    admin.address

  ]);

  return {
    admin: admin as any,
    l1Alice: l1Alice as any,
    l1Bob: l1Bob as any,
    starkNetFake: starkNetFake as any,
    l1Philand: l1philand as any,
    l2PhilandAddress: L2_PHILAND_ADDRESS,
    coupons:coupons as any,
    ens:ens as any,
    resolver:resolver as any,
    ethregistrar:ethregistrar as any
  };
}

// units
export function eth(amount: string) {
  return parseEther(amount);
}


function hexToDec(hexString: string){
  return parseInt(hexString, 16);
}

function toSplitUint(value: any) {
  const bits = value.toBigInt().toString(16).padStart(64, "0");
  return [BigInt(`0x${bits.slice(32)}`), BigInt(`0x${bits.slice(0, 32)}`)];
}


function getCoupon(addr:string){
    const CouponTypeEnum = {
      Genesis: 0,
      Author: 1,
      Presale: 2,
    };
    const coupons:any = {};
    const signerPvtKeyString = process.env.ADMIN_SIGNER_PRIVATE_KEY;
    const signerPvtKey = Buffer.from(signerPvtKeyString!, "hex");
    
    const presaleAddresses=[addr]

    for (let i = 0; i < presaleAddresses.length; i++) {
      const userAddress = ethers.utils.getAddress(presaleAddresses[i]);
      const hashBuffer = generateHashBuffer(
        ["uint256", "address"],
        [CouponTypeEnum["Presale"], userAddress]
      );
      const coupon = createCoupon(hashBuffer, signerPvtKey);
      
      coupons[userAddress] = {
        coupon: serializeCoupon(coupon)
      };
    }
    return coupons
}
// HELPER FUNCTIONS
function createCoupon(hash:any, signerPvtKey:any) {
   return ecsign(hash, signerPvtKey);
}

function generateHashBuffer(typesArray:any, valueArray:any) {
   return keccak256(
     toBuffer(ethers.utils.defaultAbiCoder.encode(typesArray,
     valueArray))
   );
}

function serializeCoupon(coupon:any) {
   return {
     r: bufferToHex(coupon.r),
     s: bufferToHex(coupon.s),
     v: coupon.v,
   };
}