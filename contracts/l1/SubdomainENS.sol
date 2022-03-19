// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;

import "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";
import '@ensdomains/ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol';

contract SubdomainENS {

    ENS internal ens; 
    ETHRegistrarController internal ensr; 

    bytes32 public cmbyte;
    bytes32 public domainNode;
    bytes32 subnode;
    
    // namehash('eth')
    bytes32 TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
    address goerliResolver = 0x4B1488B7a6B320d2D721406204aBc3eeAa9AD329;

    event NewSubdomainCreated(address sender, string subdomain);

    constructor(ENS _ens,ETHRegistrarController _ensR) {
        ens = _ens;
        ensr = _ensR;
    }
    
    function subdomainRegist(string calldata subdomain) external payable {
        string memory origin ="phi";
        
     
        domainNode = keccak256(abi.encodePacked(TLD_NODE, keccak256(bytes(origin))));
        subnode = keccak256(abi.encodePacked(domainNode,keccak256(bytes(subdomain))));
        require(ens.owner(subnode)==address(0),'already minted');
        
        ens.setSubnodeRecord(domainNode, keccak256(bytes(subdomain)), msg.sender,goerliResolver,0);
        ens.setSubnodeOwner(domainNode,keccak256(bytes(subdomain)),msg.sender);

        emit NewSubdomainCreated(msg.sender, subdomain);
    }
    function domainCommit(string calldata origin) external payable returns (bytes32)  {

        domainNode = keccak256(abi.encodePacked(TLD_NODE, keccak256(bytes(origin))));
        require(ens.owner(domainNode)==address(0),'already minted');
        cmbyte = keccak256(abi.encodePacked(keccak256(bytes(origin)), msg.sender, goerliResolver, msg.sender, domainNode));
        ensr.commit(cmbyte);
        return domainNode;
    }

}