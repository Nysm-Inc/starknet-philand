
const ethers = require('ethers');
const ABI = require('../utils/abi.json'); 
const axios = require('axios');

require('dotenv').config()

const NETWORK ="goerli"

const provider = ethers.getDefaultProvider(NETWORK);
const inter = new ethers.utils.Interface(ABI.abi);

const addr = '0x58Eb67DcA41dAC355cE0E9858bA3e8E9e867FC93'

// const concurrentPromise = async <T>(promises: (() => Promise<T>)[], concurrency: number): Promise<T[]> => {
//   const results: T[] = [];
//   let currentIndex = 0;

//   while (true) {
//     const chunks = promises.slice(currentIndex, currentIndex + concurrency);
//     console.log(chunks)
//     if (chunks.length === 0) {
//       break;
//     }
//     Array.prototype.push.apply(results, await Promise.all(chunks.map(c => c())));
//     currentIndex += concurrency;
//   }
//   return results;
// };

// const timeoutExecution = (txdata: any): Promise<any> => {
//   // eslint-disable-next-line no-async-promise-executor
//   return new Promise(function(resolve) {
//     console.log(txdata.hash)
//     resolve(provider.getTransaction(txdata.hash));
//   })}
//     // console.log(tx)
//     try{
//          const decodedInput = inter.parseTransaction({ data: tx.data, value: tx.value});
//           counter=counter+1;
//           resolve(counter);
//         }
//         catch(e){
//           console.log("skip");
//         //   // eslint-disable-next-line prefer-promise-reject-errors
//         //   reject();
//         }; 
//   });
// };

let counter =0
  async function sample() {
  const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

  // const eventBody = JSON.parse(event.body)
  const response = await axios.get(`https://api-goerli.etherscan.io/api?module=account&action=txlist&address=${addr}&startblock=0&endblock=99999999&sort=asc&apikey=${ETHERSCAN_API_KEY}`);
  const result = response.data.result;
  const result2 = await Promise.all(result.map(async (txdata:any)=>{
        const tx = await provider.getTransaction(txdata.hash);
        try{
            const decodedInput = inter.parseTransaction({ data: tx.data, value: tx.value});
        console.log({
        function_name: decodedInput.name,
        from: tx.from,
        to: decodedInput.args[0],
        erc20Value: Number(decodedInput.args[1])
        })
        counter=counter+1;
        console.log(counter)
         }
        catch(e){
          console.log("skip");
        //   // eslint-disable-next-line prefer-promise-reject-errors
        //   reject();
        }; 
    }));
  console.log(counter)
//   async () => {
// //   const promises = [result].map((_, txdata) => timeoutExecution.bind(null, txdata));
// const promises = [result].map((_, txdata){ 
// console.log(txdata);
// timeoutExecution.bind(null, txdata);
// }
// console.log(promises)
//   await concurrentPromise(promises, 5);
// }
// console.log(counter)
//   // for (const txdata of result) {
  //   console.log("start1")
  //      const tx = await provider.getTransaction(txdata.hash);
  //      console.log("start2")
  //      try{
  //        const decodedInput = inter.parseTransaction({ data: tx.data, value: tx.value});
  //        console.log("start3")
  //       // Decoded Transaction
  //        console.log({
  //           function_name: decodedInput.name,
  //           from: tx.from,
  //           to: decodedInput.args[0],
  //           erc20Value: Number(decodedInput.args[1])
  //         })
  //         counter=counter+1;
  //       }
  //       catch(e){
  //         console.log("skip");
  //       }; 
  //     }
  }
sample()