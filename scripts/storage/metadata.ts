import fs from "fs";
import { File, NFTStorage, toGatewayURL } from "nft.storage";

require("dotenv").config();

const endpoint = toGatewayURL("https://api.nft.storage");

const token = process.env.NFT_STORAGE_API_KEY || "";

const filePath = "./scripts/storage/starter/material/";
const fileBase = "Soil_Material"


async function main() {
  const storage = new NFTStorage({ endpoint, token });
  const metadata = await storage.store({
    name: "Soil",
    description:
      "Soil_Material",
    image: new File(
      [await fs.promises.readFile(filePath+fileBase+".png")],
      fileBase+".png",
      {
        type: "image/png",
      }
    ),
    base_image: new File(
      [await fs.promises.readFile(filePath+fileBase+"_under.png")],
      fileBase+"_under.png",
      {
        type: "image/png",
      }
    ),
    overlay_image: new File(
     [await fs.promises.readFile(filePath+fileBase+"_top.png")],
      fileBase+"_top.png",
      {
        type: "image/png",
      }
    ),
    attributes:[
    {"trait_type": "Size", "value": "[1,1,1]"},
    {"trait_type": "World Type", "value": "Land"},
    {"trait_type": "Object Type", "value": "Material"},
    {"trait_type": "Creator", "value": "ta2nb"}
    ]
  });

  const url = new URL(metadata.url);
  console.log(
    `HTTPS URL for the metadata: https://dweb.link/ipfs/${url.hostname}${url.pathname}`
  );
}

main();