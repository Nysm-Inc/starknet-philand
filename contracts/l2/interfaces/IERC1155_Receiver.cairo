# SPDX-License-Identifier: MIT
# OpenZeppelin Cairo Contracts v0.1.0 (token/erc721/interfaces/IERC721_Receiver.cairo)

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC1155_Receiver:
    func onERC1155Received(
        operator: felt,
        _from: felt,
        tokenId: Uint256,
        amount: felt,
        data_len: felt,
        data: felt*
    ) -> (selector: felt): 
    end
end