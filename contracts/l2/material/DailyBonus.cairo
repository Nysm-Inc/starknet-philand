%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.starknet.common.syscalls import (call_contract,
    get_caller_address,get_block_timestamp,get_contract_address)

from starkware.cairo.common.math_cmp import (is_nn_le,is_nn)
from starkware.cairo.common.uint256 import Uint256

from contracts.l2.utils.safemath import (
    uint256_checked_div_rem
) 

from contracts.l2.interfaces.IDairyMaterial import IDairyMaterial 
from contracts.l2.interfaces.IXoroshiro import IXoroshiro 


@storage_var
func _last_rnd()  -> (res : felt):
end

@storage_var
func get_last_login_time(
        owner : Uint256,
    ) -> (
        last_login_time : felt
    ):
end

@storage_var
func _IXoroshiro_address() -> (res : felt):
end

@storage_var
func _dairy_material_address() -> (res : felt):
end



##### Constants #####
# Width of the simulation grid.

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    IXoroshiro_address : felt,
    dairy_material_address : felt
    ):

    _IXoroshiro_address.write(IXoroshiro_address)
    _dairy_material_address.write(dairy_material_address)

    return ()
end


##### Public functions #####

@external
func get_next_rnd{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (rnd : felt):
    alloc_locals
    let (IXoroshiro_address) = _IXoroshiro_address.read()
    let (rnd) = IXoroshiro.next(contract_address=IXoroshiro_address)
    _last_rnd.write(rnd)
    return (rnd)
end
# 
@external
func regist_owner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : Uint256
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
    owner : Uint256,
    receive_address : felt
    ):
    alloc_locals

    let (check) = check_reward(owner)
    if check == 1:
        let (update_time) = get_block_timestamp()
        let (dairy_material_address) =  _dairy_material_address.read()

        get_last_login_time.write(owner,update_time)
        let (rnd)=get_next_rnd()
        let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(4,0))

        # soil
        if rem.low == 0:
            IDairyMaterial._mint(dairy_material_address,receive_address,Uint256(0,0),1)
            return ()
        end

        # oil
        if rem.low == 1:
            IDairyMaterial._mint(dairy_material_address,receive_address,Uint256(1,0),1)
            return ()
        end

        # seed
        if rem.low == 2:
            IDairyMaterial._mint(dairy_material_address,receive_address,Uint256(2,0),1)
            return ()
        end

        #  iron
        if rem.low == 3:
            IDairyMaterial._mint(dairy_material_address,receive_address,Uint256(3,0),1)
            return ()
        end
        return ()
    else:
        return ()
    end
    
end



@view
func get_login_time{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : Uint256
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
    owner : Uint256
    )-> (
    elapsed_time : felt
    ):
    alloc_locals
    let (local last_login_time)= get_last_login_time.read(owner)
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_login_time
    return (elapsed_time)
end 

@view
func check_reward{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : Uint256
    )-> (
    flg : felt
    ):
    alloc_locals
    let (local last_login_time) = get_last_login_time.read(owner)
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_login_time
    
    let (local flg) = is_nn(elapsed_time - 100)
    
    return (flg)
end 

@view
func get_latest_rnd{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (rnd : felt):
    alloc_locals
    let (rnd)=_last_rnd.read()
    return (rnd)
end

@view
func get_latest_100div_rnd{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (c : Uint256, rem : Uint256):
    alloc_locals
    let (rnd)=_last_rnd.read()
    let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(100,0))
    return (c,rem)
end

@view
func dairy_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _dairy_material_address.read()
    return (res)
end