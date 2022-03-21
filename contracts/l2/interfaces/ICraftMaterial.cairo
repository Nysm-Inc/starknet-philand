%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ICraftMaterial:

    func _mint(to : felt, token_id : Uint256, amount : felt):
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
end