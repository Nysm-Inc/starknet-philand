import fs from "fs";
import { File, NFTStorage, toGatewayURL } from "nft.storage";

require("dotenv").config();

const endpoint = toGatewayURL("https://api.nft.storage");
const token = process.env.NFT_STORAGE_API_KEY || "";

async function main() {
  const storage = new NFTStorage({ endpoint, token });
  const metadata = await storage.store({
    name: "philand object store test",
    description:
      "starter kit Object 2.",
    image: new File(
      [await fs.promises.readFile("./scripts/storage/assets/2.png")],
      "2.png",
      {
        type: "image/png",
      }
    ),
  });

  const url = new URL(metadata.url);
  console.log(
    `HTTPS URL for the metadata: https://dweb.link/ipfs/${url.hostname}${url.pathname}`
  );
}

main();