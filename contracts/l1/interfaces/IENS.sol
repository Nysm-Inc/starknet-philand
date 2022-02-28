// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;


interface IENS {
    function resolver(bytes32 node) external view returns (Resolver);
    function owner(bytes32 node) external view returns (address);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}