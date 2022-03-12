import { smock } from "@defi-wonderland/smock";
import { parseFixed } from "@ethersproject/bignumber";
import {
  simpleDeploy
} from "@makerdao/hardhat-utils";
import chai, { expect } from "chai";
import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";

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

const createPhiland = parseFixed(
  "617099311689109934115201364618365113888900634692095419483864089403220532029"
);

// const claimL1Object = parseFixed(
//   "1426524085905910661260502794228018787518743932072178038305015687841949115798"
// );

const claimL2Object = parseFixed(
  "725729645710710348624275617047258825327720453914706103365608274738200251740"
);


  // const name_int = split uint 55354291560282261680205140228934436588969903936754548205611172710617586860032
  const name_int = [parseFixed("200906542797035968731773474540731270692"),parseFixed("219828944448636554577399085665499793739")]

// str_to_felt('zak3939.eth')=147948997034476692113290344
  // const ENSLABEL =web3.utils.asciiToHex('zak3939.eth')
  // const ENSLABEL =web3.utils.asciiToHex('zak3939')
  const ENSLABEL = ethers.utils.formatBytes32String('zak3939')
  console.log(ENSLABEL)
  const ENSNAME= BigInt(ENSLABEL).toString(10)
  console.log(ENSNAME)
  const SUBENSLABEL = ethers.utils.formatBytes32String('test.zak3939')
  console.log(SUBENSLABEL)
  const SUBENSNAME= BigInt(SUBENSLABEL).toString(10)
  console.log(SUBENSNAME)
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
      const { admin,l1Alice, starkNetFake, l1Philand, l2PhilandAddress,ens,resolver, } =
        await setupTest();

      await ens.setSubnodeOwner(namehash.hash(""), sha3('eth'), admin.address);
      await ens.connect(admin).setSubnodeOwner(namehash.hash('eth'), sha3('zak3939'),l1Alice.address)
      await ens.connect(l1Alice).setResolver(namehash.hash('zak3939.eth'),resolver.address)
      await resolver.setAddr(namehash.hash('zak3939.eth'), l1Alice.address);
      await ens.resolver(namehash.hash('zak3939.eth'))
      await expect(l1Philand.connect(l1Alice).createPhiland(l2PhilandAddress, 'zak3939'))
        .to.emit(l1Philand, "LogCreatePhiland")
        .withArgs(l1Alice.address,'zak3939');

      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        createPhiland,
        [name_int[0],name_int[1]]
      );
    });   
});

// describe("createPhilandwithsubdomain", function () {
//     it("sends a message to l2, emits event", async () => {
//       const { admin,l1Alice, starkNetFake, l1Philand, l2PhilandAddress,ens,resolver, } =
//         await setupTest();

//       await ens.setSubnodeOwner(namehash.hash(""), sha3('eth'), admin.address);
//       await ens.connect(admin).setSubnodeOwner(namehash.hash('eth'), sha3('zak3939'),l1Alice.address)
//       await ens.connect(l1Alice).setSubnodeOwner(namehash.hash('zak3939.eth'), sha3('test'),l1Alice.address)
//       // await ens.connect(l1Alice).setResolver(namehash.hash('zak3939.eth'),resolver.address)
//       // await resolver.setAddr(namehash.hash('zak3939.eth'), l1Alice.address);
//       // await ens.resolver(namehash.hash('zak3939.eth'))

      
//       await ens.connect(l1Alice).setResolver(namehash.hash('test.zak3939.eth'),resolver.address)
//       await resolver.setAddr(namehash.hash('test.zak3939.eth'), l1Alice.address);
//       await ens.resolver(namehash.hash('test.zak3939.eth'))


//       await expect(l1Philand.connect(l1Alice).createPhiland(l2PhilandAddress, 'test.zak3939'))
//         .to.emit(l1Philand, "LogCreatePhiland")
//         .withArgs(l1Alice.address,'test.zak3939');

//       expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
//       expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
//         l2PhilandAddress,
//         createPhiland,
//         [name_int[0],name_int[1]]
//       );
//     });   
// });
// describe("claimL1NFT", function () {
//     it("sends a message to l2, claim nft event", async () => {
//       const { l1Alice, starkNetFake, l1Philand, l2PhilandAddress } =
//         await setupTest();
  
//       const lootContract = "0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7"
//       const tokenid = 13
//       await expect(l1Philand.connect(l1Alice).claimL1Object(l2PhilandAddress, 'zak3939',lootContract,tokenid))
//         .to.emit(l1Philand, "LogClaimL1NFT")
//         .withArgs('zak3939',lootContract,tokenid);

//       expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
//       expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
//         l2PhilandAddress,
//         claimL1Object,
//         [ENSNAME,lootContract,tokenid]
//       );
//     });
// });

describe("claiml2Object", function () {
    it("sends a message to l2, claim nft event", async () => {
      const { admin,l1Alice, starkNetFake, l1Philand, l2PhilandAddress,l2UserAddress,coupons } =
        await setupTest();
  
      const tokenid = 6
      const condition = "lootbalance"
      
      const conditionTX = await l1Philand.connect(admin).setCouponType(condition,1)
      await conditionTX.wait()
      console.log(await l1Philand.connect(l1Alice).getCouponType(condition))
      expect(await l1Philand.connect(l1Alice).getCouponType(condition)).to.equal(1)

      await expect(l1Philand.connect(l1Alice).claimL2Object(l2PhilandAddress, 'zak3939',l2UserAddress,tokenid,condition,coupons[l1Alice.address]["coupon"]))
        .to.emit(l1Philand, "LogClaimL2Object")
        .withArgs('zak3939',l2UserAddress,tokenid);
      console.log("finish")
      
      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        claimL2Object,
        [name_int[0],name_int[1],l2UserAddress,6,0]
      );
    });
});




async function setupTest() {
  const [admin, l1Alice, l1Bob] = await hre.ethers.getSigners();

  const starkNetFake = await smock.fake("IStarkNetLike");
  const L2_PHILAND_ADDRESS = 31415;
  const L2_USER_ADDRESS = 11111;
  
  const ens = await simpleDeploy("ENSRegistry",[]);
  const resolver = await simpleDeploy("TestResolver",[]);
  const ethregistrar= await simpleDeploy("TestRegistrar",[ens.address,
      namehash.hash('eth'),]);

  const coupons = getCoupon(l1Alice.address)
  const l1philand = await simpleDeploy("MessageENS", [
    starkNetFake.address,
    ens.address,
    admin.address
  ]);

  return {
    admin: admin as any,
    l1Alice: l1Alice as any,
    l1Bob: l1Bob as any,
    starkNetFake: starkNetFake as any,
    l1Philand: l1philand as any,
    l2PhilandAddress: L2_PHILAND_ADDRESS,
    l2UserAddress: L2_USER_ADDRESS,
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


// function hexToDec(hexString: string){
//   return parseInt(hexString, 16);
// }


function getCoupon(addr:string){
    const CouponTypeEnum = {
    lootbalance:1,
    uniswap1:2,
    uniswap5:3,
    uniswap10:4,
    snapshot:5,
    ethbalance1:6
    };
    const coupons:any = {};
    const signerPvtKeyString = process.env.ADMIN_SIGNER_PRIVATE_KEY;
    const signerPvtKey = Buffer.from(signerPvtKeyString!, "hex");
    
    const presaleAddresses=[addr];
    console.log(CouponTypeEnum["lootbalance"]);
    for (let i = 0; i < presaleAddresses.length; i++) {
      const userAddress = ethers.utils.getAddress(presaleAddresses[i]);
      const hashBuffer = generateHashBuffer(
        ["uint256", "address"],
        [CouponTypeEnum["lootbalance"], userAddress]
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