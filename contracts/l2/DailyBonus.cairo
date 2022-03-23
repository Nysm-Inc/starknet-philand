%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.starknet.common.syscalls import (call_contract,get_block_number,
    get_caller_address,get_block_timestamp,get_contract_address)

from starkware.cairo.common.math_cmp import (is_nn_le,is_nn)
from starkware.cairo.common.uint256 import Uint256

from contracts.l2.token.IERC20 import IERC20
from contracts.l2.utils.safemath import (
    uint256_checked_div_rem
) 

from contracts.l2.interfaces.IDailyMaterial import IDailyMaterial 
from contracts.l2.interfaces.IXoroshiro import IXoroshiro 


@storage_var
func _last_rnd()  -> (res : felt):
end

@storage_var
func _fee()  -> (res : Uint256):
end

@storage_var
func _treasurey_address()  -> (res : felt):
end

@storage_var
func get_last_login_time(
        owner : felt,
    ) -> (
        last_login_time : felt
    ):
end

@storage_var
func _actual_result_gold(block_number : felt)  -> (res : felt):
end

@storage_var
func _gold_parcent(block_number : felt)  -> (res : felt):
end

@storage_var
func _actual_result_crystal(block_number : felt )  -> (res : felt):
end

@storage_var
func _IXoroshiro_address() -> (res : felt):
end

@storage_var
func _daily_material_address() -> (res : felt):
end

@storage_var
func _erc20Address()  -> (res : felt):
end

@storage_var
func _treasury_address()  -> (res : felt):
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
    daily_material_address : felt,
    erc20Address : felt,
    treasury_address : felt
    ):

    _IXoroshiro_address.write(IXoroshiro_address)
    _daily_material_address.write(daily_material_address)
    _erc20Address.write(erc20Address)
    _treasurey_address.write(treasury_address)

    let (currentBlock) = get_block_number()
    _gold_parcent.write(currentBlock,50)

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
    ):
    alloc_locals

    let (check) = check_reward(owner)
    if check == 1:
        let (update_time) = get_block_timestamp()
        let (daily_material_address) =  _daily_material_address.read()

        get_last_login_time.write(owner,update_time)
        let (rnd)=get_next_rnd()
        let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(4,0))

        # soil
        if rem.low == 0:
            IDailyMaterial._mint(daily_material_address,owner,Uint256(0,0),1)
            return ()
        end

        # oil
        if rem.low == 1:
            IDailyMaterial._mint(daily_material_address,owner,Uint256(1,0),1)
            return ()
        end

        # seed
        if rem.low == 2:
            IDailyMaterial._mint(daily_material_address,owner,Uint256(2,0),1)
            return ()
        end

        #  iron
        if rem.low == 3:
            IDailyMaterial._mint(daily_material_address,owner,Uint256(3,0),1)
            return ()
        end
        return ()
    else:
        return ()
    end
    
end

@external
func get_reward2{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    ):
    alloc_locals

    let (check) = check_reward(owner)
    # if check == 1:
    let (update_time) = get_block_timestamp()
    let (daily_material_address) =  _daily_material_address.read()

    # get_last_login_time.write(owner,update_time)
    let (rnd)=get_next_rnd()
    let (currentBlock) = get_block_number()
    let (gold_parcent) = _gold_parcent.read(currentBlock)

    
    let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(100,0))
    let (local check) = is_nn_le(rem.low, gold_parcent)

    let (user) = get_caller_address()
    let (fee) = get_fee()
    let (erc20Address) = _erc20Address.read()
    let (treasurey_address) = _treasurey_address.read()

        # Transfer ERC20 payment from buyer to seller
        IERC20.transferFrom(
            erc20Address,
            user,
            treasurey_address,
            fee,
        )
      
        # soil
        if check == 0:
            IDailyMaterial._mint(daily_material_address,owner,Uint256(0,0),1)
            return ()
        end

        # # gas
        # if rem.low == 5:
        #     IDailyMaterial._mint(daily_material_address,owner,Uint256(5,0),1)
        #     return ()
        # end

        # gold
        if check == 1:
            IDailyMaterial._mint(daily_material_address,owner,Uint256(6,0),1)
            return ()
        end

        # #  crystal
        # if rem.low == 7:
        #     IDailyMaterial._mint(daily_material_address,owner,Uint256(7,0),1)
        #     return ()
        # end
        return ()
    # else:
    #     return ()
    # end
    
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

@view
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
func get_fee{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }() -> (
        res : Uint256
    ):
    alloc_locals

    let (res) = _fee.read()
    return (res)
end

@view
func daily_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _daily_material_address.read()
    return (res)
end