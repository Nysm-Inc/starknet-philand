%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct ObjectSize:
    member x : felt
    member y : felt
    member z : felt
end

@contract_interface
namespace IPhiObject:

    func _mint(to : felt, token_id : Uint256, amount : felt):
    end
    
    func _mint_batch(to : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt,amounts : felt*):
    end

    func _burn(_from : felt, token_id : Uint256, amount : felt):
    end

    func _burn_batch(
        _from : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt, amounts : felt*):
    end

    func balance_of(owner : felt, token_id : Uint256) -> (res : felt):
    end

    func balance_of_batch(
        owners_len : felt, owners : felt*, tokens_id_len : felt, tokens_id : Uint256*) -> (
        res_len : felt, res : felt*):
    end

    func safe_transfer_from(_from : felt, to : felt, token_id : Uint256, amount : felt):
    end

    func get_size(token_id : Uint256) -> (objectSize : ObjectSize):
    end

    func setTokenURI(token_uri_len : felt, token_uri : felt*, token_id : Uint256):
    end

end