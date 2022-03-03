%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.starknet.common.syscalls import (call_contract,
    get_caller_address,get_block_timestamp,get_contract_address)

from starkware.cairo.common.math_cmp import (is_nn_le)

@storage_var
func get_last_login_time(
        owner : felt,
    ) -> (
        last_login_time : felt
    ):
end


@storage_var
func _material_address() -> (res : felt):
end



@contract_interface
namespace IMaterial:

    func _mint(to : felt, token_id : felt, amount : felt):
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
func regist_owner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    ):
    alloc_locals
    let (local update_time) = get_block_timestamp()
    get_last_login_time.write(owner,update_time)
    return ()
end

@external
func get_reward{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    owner_address : felt
    )->(check : felt ):
    alloc_locals


    let (check) = check_reward(owner)
    if check == 1:
        let (local update_time) = get_block_timestamp()
        get_last_login_time.write(owner,update_time)
        let (local material_address) = _material_address.read()
        IMaterial._mint(material_address,owner_address,1,1)
        return (check)
    else:
        return (check)
    end

    
end

@view
func get_login_time{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    )-> (
    last_login_time : felt
    ):
    alloc_locals
    let (last_login_time)= get_last_login_time.read(owner)

    return (last_login_time)
end 

@view
func check_elapsed_time{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    )-> (
    elapsed_time : felt
    ):
    alloc_locals
    let (local last_login_time)= get_last_login_time.read(owner)
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_login_time
    return (elapsed_time)
end 

func check_reward{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    )-> (
    flg : felt
    ):
    alloc_locals
    let (local last_login_time) = get_last_login_time.read(owner)
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_login_time
    
    let (local flg) = is_nn_le(elapsed_time, 100)
    
    return (flg)
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