import { smock } from "@defi-wonderland/smock";
import { parseFixed } from "@ethersproject/bignumber";
import {
  simpleDeploy
} from "@makerdao/hardhat-utils";
import chai, { expect } from "chai";
import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";

chai.use(smock.matchers);

const createGrid = parseFixed(
  "230744737155971716570284140634551213064188756564393274009046094202533668423"
);

const claimL1Object = parseFixed(
  "1426524085905910661260502794228018787518743932072178038305015687841949115798"
);

// str_to_felt('zak3939.eth')=147948997034476692113290344
const ENSNAME =BigInt(147948997034476692113290344)

  describe("createPhiland", function () {
    it("sends a message to l2, emits event", async () => {
      const { l1Alice, starkNetFake, l1Philand, l2PhilandAddress } =
        await setupTest();
        
      const grid_x = 0;
      const grid_y = 0;

      await expect(l1Philand.connect(l1Alice).createPhiland(l2PhilandAddress, grid_x,grid_y,ENSNAME))
        .to.emit(l1Philand, "LogCreatePhiland")
        .withArgs(l1Alice.address, grid_x, grid_y,ENSNAME);

      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        createGrid,
        [grid_x,grid_y , ENSNAME]
      );
    });
    
});

describe("claiml1Object", function () {
    it("sends a message to l2, claim nft event", async () => {
      const { l1Alice, starkNetFake, l1Philand, l2PhilandAddress } =
        await setupTest();
  
      const lootContract = "0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7"
      // const lootContract = 120
      
        // const lootContract =BigNumber.from("26503913489432437679275880480520920575459601716508079830908297991757361670997849764161193493583316023")
      // const lootContract = hexToDec("0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7")
      // const lootContract =BigInt(26503913489432437679275880480520920575459601716508079830908297991757361670997849764161193493583316023)
      const tokenid = 13
      await expect(l1Philand.connect(l1Alice).claimObject(l2PhilandAddress, ENSNAME,lootContract,tokenid))
        .to.emit(l1Philand, "LogClaimObject")
        .withArgs(ENSNAME,lootContract,tokenid);

      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        claimL1Object,
        [ENSNAME,lootContract,tokenid]
      );

    });
    
});

async function setupTest() {
  const [admin, l1Alice, l1Bob] = await hre.ethers.getSigners();

  const starkNetFake = await smock.fake("IStarknetCore");
  const L2_PHILAND_ADDRESS = 31415;

  const l1philand = await simpleDeploy("PhilandL1", [
    starkNetFake.address,
    // L2_PHILAND_ADDRESS,
  ]);

  return {
    admin: admin as any,
    l1Alice: l1Alice as any,
    l1Bob: l1Bob as any,
    starkNetFake: starkNetFake as any,
    l1Philand: l1philand as any,
    l2PhilandAddress: L2_PHILAND_ADDRESS,
  };
}

// units
export function eth(amount: string) {
  return parseEther(amount);
}

function hexToDec(hexString: string){
  return parseInt(hexString, 16);
}