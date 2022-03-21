%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IObject:
    
    func _mint(to : felt, token_id : Uint256, amount : felt):
    end

    func _mint_batch(to : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt, amounts : felt*):
    end

    func _burn(_from : felt, token_id : Uint256, amount : felt):
    end

    func balanceOf(user : felt, token_id : Uint256) -> (res : felt):
    end

    func setTokenURI(token_uri_len : felt, token_uri : felt*,token_id : Uint256):
    end

end