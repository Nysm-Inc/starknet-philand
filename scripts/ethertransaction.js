
const ethers = require('ethers');
const ABI = require('./utils/abi.json'); 
const axios = require('axios');
const crypto = require("crypto");
const {
  keccak256,
  toBuffer,
  ecsign,
  bufferToHex,
} = require("ethereumjs-utils");
require('dotenv').config()

const addr = '0x58Eb67DcA41dAC355cE0E9858bA3e8E9e867FC93'
const addr2 = "0x08Af551159b74ef9884CF7FdEd527F67fcb0feA6"

const NETWORK ="goerli"

const CouponTypeEnum = {
  Genesis: 0,
  Author: 1,
  Presale: 2,
};
let coupons = {};

const provider = ethers.getDefaultProvider(NETWORK);
const inter = new ethers.utils.Interface(ABI.abi);


// HELPER FUNCTIONS
function createCoupon(hash, signerPvtKey) {
   return ecsign(hash, signerPvtKey);
}

function generateHashBuffer(typesArray, valueArray) {
   return keccak256(
     toBuffer(ethers.utils.defaultAbiCoder.encode(typesArray,
     valueArray))
   );
}

function serializeCoupon(coupon) {
   return {
     r: bufferToHex(coupon.r),
     s: bufferToHex(coupon.s),
     v: coupon.v,
   };
}


  
  async function sample() {
  const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

  // const eventBody = JSON.parse(event.body)
  const response = await axios.get(`https://api-goerli.etherscan.io/api?module=account&action=txlist&address=${addr}&startblock=0&endblock=99999999&sort=asc&apikey=${ETHERSCAN_API_KEY}`);
  const result = response.data.result
  let counter =0
  for (const txdata of result) {
       const tx = await provider.getTransaction(txdata.hash);
       try{
         const decodedInput = inter.parseTransaction({ data: tx.data, value: tx.value});
        // Decoded Transaction
         console.log({
            function_name: decodedInput.name,
            from: tx.from,
            to: decodedInput.args[0],
            erc20Value: Number(decodedInput.args[1])
          })
          counter=counter+1;
        }
        catch(e){
          console.log("skip");
        }; 
      }
    console.log(counter);

    const signerPvtKeyString = process.env.ADMIN_SIGNER_PRIVATE_KEY;
    const signerPvtKey = Buffer.from(signerPvtKeyString, "hex");
    const presaleAddresses=[addr,addr2]

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
    console.log(coupons)
  }
sample()