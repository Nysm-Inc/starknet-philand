import { smock } from "@defi-wonderland/smock";
import { parseFixed } from "@ethersproject/bignumber";
import {
  simpleDeploy
} from "@makerdao/hardhat-utils";
import chai, { expect } from "chai";
import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";

chai.use(smock.matchers);

const createPhiland = parseFixed(
  "230744737155971716570284140634551213064188756564393274009046094202533668423"
);

  describe("createPhiland", function () {
    it("sends a message to l2, emits event", async () => {
      const { l1Alice, starkNetFake, l1Philand, l2PhilandAddress } =
        await setupTest();
        
      const grid_x = 0;
      const grid_y = 0;
      const ensname = BigInt(147948997034476692113290344);

      await expect(l1Philand.connect(l1Alice).createPhiland(l2PhilandAddress, grid_x,grid_y,ensname))
        .to.emit(l1Philand, "LogCreatePhiland")
        .withArgs(l1Alice.address, grid_x, grid_y,ensname);

      expect(starkNetFake.sendMessageToL2).to.have.been.calledOnce;
      expect(starkNetFake.sendMessageToL2).to.have.been.calledWith(
        l2PhilandAddress,
        createPhiland,
        [grid_x,grid_y , ensname]
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
