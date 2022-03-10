// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;

interface IStarkNetLike {
    /**
      Sends a message to an L2 contract.
      Returns the hash of the message.
    */
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) external;
}