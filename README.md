## About

This is starknet Metamaterial/Phi test repository

## What is MetaMaterial

A protocol that allows game players to transfer any items between games.
We made many kinds NFTs with string data, which works ad a material, avatar, weapon,...
game players can convert these NFTs to use in various game.

## What is Phi

Phi is a protocol for creating an open and fair Metaverse. While Sandbox adopted the concept of NFT into the metaverse, it hasn't adopted Blockchain's fairness, openness, and network effects.
So we are trying to adopt these blockchain features into Metaverse. Phi is a completely new bottom-up Metaverse that everyone can participate in, extend, connect, and edit. Phi adopts Internet mechanisms to the Metaverse, creating a standard of value that is independent of the size and location of the land and stimulating user creativity.

## Sub-folders

`/contracts` - Solidity/Cairo contracts as deployed on-chain

## Demo

### Metamaterial 

<https://meta-material-frontend.vercel.app/>

    - Create ERC1155
        -  player can mint/burn 10 material at 1 time
        -  static data for token supply and burn
    - Random minting (token_id 0,1,2,3)with pseudorandom number
    - Allow players to mint 1 Material 1Day with checking block timestamp
    - Metadata is uploaded on arwearve
    <https://github.com/Nysm-Inc/arwearve-upload>
    - Defi-like NFT usages with ERC1155
        NFT swap/wrap
    - Export wrapped NFTs to Other Dapps
        => Case study is Phi
### Phi(Usecase)

<https://next-sandbox-nine.vercel.app/>

    - L1 contract on Ethereum(Goerli Testnet)
        - to message the permission of minting an Object NFT to L2 based on the coupon.
        - to confirm the holders of NFTs on L1.
        - to check ENS resolver.
    - L2 map contract on StarkNet (Goerli Testnet) to generate a virtual land and to write the location information of the Objects.
    - L2 contract on StarkNet (Goerli Testnet) to mint Object NFTs by ERC1155
    - L2 contract on StarkNet (Goerli Testnet) to mint Material NFT as Login Bonus
    - Link system of map contracts to connect lands.
    - Using NFT storage to store the pixel arts
    - Using Covalent API, Graph, EtherScan to get user’s wallet activit
Learn more
There is a long document about the project on the [Phi](https://medium.com/@phi.xyz/introducing-phi-a-blockchain-native-metaverse-with-ens-and-on-chain-activities-1f5bb1a02eed). Start there and we'll add to this guide as questions come up.

### Off-Chain Solution: 

in phi, we use this offchain validation for object claim
On-chain activity history validation system by using AWS (<https://github.com/Nysm-Inc/philand-cdk>).

## Contract Architecture

![Contract Overview](/ark.png)


## Check by this command
(need docker install)

```
- `python3 -m venv .venv`: Create a virtualenv` on MacOS and Linux
- `source .venv/bin/activate`: Activate your virtualenv
- pip install -r requirements.txt
- yarn compile
- yarn test:l1 & yarn test:l2
- yarn deploy-deployer:goerli
- yarn deploy-bridge:goerli
```
## Acknowledgments

- <https://github.com/0xs34n/starknet.js>
- <https://github.com/playoasis/starknet-contracts>
- <https://github.com/OpenZeppelin/openzeppelin-contracts>
- <https://github.com/perama-v/GoL2>
- <https://github.com/makerdao/starknet-dai-bridge>
- <https://github.com/Arachnid/solidity-stringutils>
- <https://betterprogramming.pub/handling-nft-presale-allow-lists-off-chain-47a3eb466e44>
- <https://hackmd.io/@RoboTeddy/BJZFu56wF>
- <https://perama-v.github.io/cairo/game/world>
- <https://www.cairo-lang.org/docs/hello_starknet/>
- <https://buildquest.ethglobal.com/>
- <https://github.com/threepwave/cryptsandcaverns>
- <https://github.com/milancermak/xoroshiro-cairo>

## Contribute

I want to build with you. Join the [Phi discord](https://discord.gg/phi) and share your ideas!
