%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.starknet.common.syscalls import (call_contract,
    get_caller_address,get_block_timestamp,get_contract_address)
from starkware.cairo.common.math import (unsigned_div_rem, assert_nn,
    assert_not_zero, assert_nn_le, assert_le, assert_not_equal,
    split_int)
    
from starkware.cairo.common.math_cmp import (is_nn_le,is_nn)
from starkware.cairo.common.uint256 import Uint256

@storage_var
func get_last_login_time(
        owner : Uint256,
    ) -> (
        last_login_time : felt
    ):
end


@storage_var
func _material_address() -> (res : felt):
end



@contract_interface
namespace IMaterial:

    func _mint(to : felt, token_id : Uint256, amount : felt):
    end

    func _burn(_from : felt, token_id : Uint256, amount : felt):
    end

    func balance_of(user : felt, token_id : Uint256) -> (res : felt):
    end

    func safe_transfer_from(_from : felt, to : felt, token_id : Uint256, amount : felt):
    end
end

##### Constants #####
# Width of the simulation grid.

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    material_address : felt
    ):
    
    _material_address.write(material_address)

    return ()
end


##### Public functions #####
# 
@external
func soil_2_brick{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    sender_address : felt
    ):
    alloc_locals
    # Check user has enough funds.
    let (material_address) = _material_address.read()
    let (account_from_balance) = IMaterial.balance_of(material_address,
        user=sender_address, token_id=Uint256(1,0))
    assert_le(4,account_from_balance)

    IMaterial._burn(material_address,_from =sender_address, token_id = Uint256(1,0), amount=4)
    IMaterial._mint(material_address,to=sender_address, token_id=Uint256(2,0), amount=1)
    return ()
end


@view
func material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _material_address.read()
    return (res)
end