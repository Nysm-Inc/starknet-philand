%lang starknet
%builtins pedersen range_check bitwise

# // SPDX-License-Identifier: GPL-2.0-or-later
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.cairo.common.math import (unsigned_div_rem, assert_nn,
    assert_not_zero, assert_nn_le, assert_le, assert_not_equal,assert_in_range,
    split_int)
from starkware.cairo.common.math_cmp import (
    is_not_zero, is_nn, is_le, is_nn_le, is_in_range,
    is_le_felt)
from starkware.starknet.common.syscalls import (call_contract,
    get_caller_address,get_block_timestamp,get_contract_address)
from starkware.cairo.common.uint256 import (Uint256, uint256_le,uint256_eq)
from contracts.l2.utils.Ownable_base import (
    Ownable_initializer,
    Ownable_only_owner,
    Ownable_transfer_ownership,
    Ownable_get_owner
)
##### Description #####
#
# Management of philand's map contract
#
#######################

##### Interfacess #####
from contracts.l2.interfaces.IPhiObject import IPhiObject

##### Constants #####
from contracts.l2.utils.constants import FALSE, TRUE
const DIM_X = 10
const DIM_Y = 10


##### Event #####
@event
func create_philan_event(user : Uint256, l2user : felt):
end


##### Struct #####
struct PhilandObjectInfo:
    member contract_address : felt
    member token_id : Uint256
    member x_start : felt
    member y_start : felt
    member x_end : felt
    member y_end : felt
end

struct ObjectSize:
    member x : felt
    member y : felt
    member z : felt
end

##### Storage #####
@storage_var
func user_deposit_object(user: Uint256,contract_address: felt,token_id:Uint256) -> (res : felt):
end


@storage_var
func user_philand_object_idx(user: Uint256) -> (res : felt):
end

@storage_var
func user_philand_object(user: Uint256, idx: felt) -> (res : PhilandObjectInfo):
end

@storage_var
func claimed_user(
        user : Uint256,
    ) -> (
        res : felt
    ):
end

@storage_var
func mapping_ens_l2account(
        user : Uint256,
    ) -> (
        res : felt
    ):
end

@storage_var
func number_of_philand(
    ) -> (
         res : felt
    ):
end

##### Contract Address #####

@storage_var
func _object_address() -> (res : felt):
end

@storage_var
func _l1_philand_address() -> (res : felt):
end

@view
func object_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _object_address.read()
    return (res)
end

@view
func l1_philand_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _l1_philand_address.read()
    return (res)
end

##################
@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    object_address : felt,
    l1_philand_address : felt,
    ):

    let (caller) = get_caller_address()
    Ownable_initializer(caller)

    number_of_philand.write(0)
    _object_address.write(object_address)
    _l1_philand_address.write(l1_philand_address)

    return ()
end


#############################
##### Map functions #####
#############################
# Receive an L1 message. The Sequencer actions this function.
# Sets the initial state of a philand.
@l1_handler
func create_philand{
        syscall_ptr : felt*,
        bitwise_ptr : BitwiseBuiltin*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(  
        from_address : felt, 
        user_low : felt,
        user_high : felt,
        l2account : felt
    ):
    alloc_locals
    let user : Uint256 = Uint256(user_low,user_high)
    create_philan_event.emit(user,l2account)
    claimed_user.write(user,TRUE)
    mapping_ens_l2account.write(user,l2account)
    # assert_not_zero(user)
    let (res) = number_of_philand.read()
    let index = res +1
    number_of_philand.write(index)
    return ()
end

func check_collision{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    user : Uint256,
    writeObject : PhilandObjectInfo
    ) -> ():
    alloc_locals
    let (object_len)= user_philand_object_idx.read(user=user)
    populate_check_collision(user,object_len,writeObject)
    return ()
end

func populate_check_collision{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    user : Uint256,
    object_len : felt,
    writeObject : PhilandObjectInfo
    ) -> ():
    alloc_locals
    
    let check = 1

    assert_in_range(writeObject.x_start, 0, DIM_X + 1 )
    assert_in_range(writeObject.x_end, 0, DIM_X + 1 )
    assert_in_range(writeObject.y_start, 0, DIM_Y+ 1 )
    assert_in_range(writeObject.y_end, 0, DIM_Y+ 1 )
    let (object)= user_philand_object.read(user=user,idx=object_len)
   
    let (local a) = is_le(writeObject.x_end,object.x_start)
    if a ==1:
        if object_len == 0:
            return ()
        end
        populate_check_collision(user=user, object_len=object_len - 1,writeObject=writeObject)
        return()
    end
    let (local b) = is_le(object.x_end,writeObject.x_start)
    if b ==1:
        if object_len == 0:
            return ()
        end
        populate_check_collision(user=user, object_len=object_len - 1,writeObject=writeObject)
        return()
    end
    let (local c) = is_le(writeObject.y_end,object.y_start)
    if c ==1:
        if object_len == 0:
            return ()
        end
        populate_check_collision(user=user, object_len=object_len - 1,writeObject=writeObject)
        return()
    end
    let (local d) = is_le(object.y_end,writeObject.y_start)
    if d ==1:
        if object_len == 0:
            return ()
        end
        populate_check_collision(user=user, object_len=object_len - 1,writeObject=writeObject)
        return()
    end
    assert check = 0
    
    return ()
end

@external
func write_object_to_land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(  
        user : Uint256,
        x_start : felt,
        y_start : felt,
        contract_address : felt,
        token_id : Uint256
    ):
    alloc_locals
    with_attr error_message("caller ens owner dose not match"):
        let (caller) = get_caller_address()
        let (l2account) = mapping_ens_l2account.read(user)
        assert  caller=l2account
    end
    let size : ObjectSize = IPhiObject.get_size(contract_address,token_id)
    let philandObjectInfo : PhilandObjectInfo = PhilandObjectInfo(
        contract_address =  contract_address,
        token_id = token_id,
        x_start=x_start,
        y_start=y_start,
        x_end = x_start + size.x,
        y_end = y_start+size.y,
    )

    let (local idx)=user_philand_object_idx.read(user=user)
    if idx == 0:
        user_philand_object.write(user=user, idx=idx, value = philandObjectInfo)
        user_philand_object_idx.write(user=user,value=idx + 1)
        return ()
    end

    check_collision(user=user,writeObject=philandObjectInfo)
    user_philand_object.write(user=user, idx=idx, value = philandObjectInfo)
    user_philand_object_idx.write(user=user,value=idx + 1)
    return ()
end

@external
func batch_write_object_to_land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        x_start_len : felt,
        x_start : felt*,
        y_start_len : felt,
        y_start : felt*,
        contract_address_len : felt,
        contract_address : felt*,
        token_id_len : felt,
        token_id : Uint256*
    ):
    assert x_start_len = y_start_len
    if x_start_len == 0:
        return ()
    end
    with_attr error_message("caller ens owner dose not match"):
        let (caller) = get_caller_address()
        let (l2account) = mapping_ens_l2account.read(user)
        assert  caller=l2account
    end
    write_object_to_land(user, [x_start], [y_start],[contract_address],[token_id])
    return batch_write_object_to_land(
        user = user,
        x_start_len = x_start_len - 1,
        x_start = x_start + 1,
        y_start_len = y_start_len - 1,
        y_start = y_start + 1,
        contract_address_len = contract_address_len - 1,
        contract_address = contract_address + 1,
        token_id_len = token_id_len - 1,
        token_id = token_id + 2
        )
end

@external
func remove_object_from_land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        idx : felt
    ):
    alloc_locals
    with_attr error_message("caller ens owner dose not match"):
        let (caller) = get_caller_address()
        let (l2account) = mapping_ens_l2account.read(user)
        assert  caller=l2account
    end
    let emptyPhilandObjectInfo : PhilandObjectInfo = PhilandObjectInfo(
        contract_address =  0,
        token_id = Uint256(0, 0),
        x_start = 0,
        y_start = 0,
        x_end =  0,
        y_end =  0,
    )
    user_philand_object.write(user=user, idx=idx, value = emptyPhilandObjectInfo)
    return ()
end

@external
func batch_remove_object_from_land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        idx_len : felt,
        idx : felt*
    ):
    alloc_locals
    with_attr error_message("caller ens owner dose not match"):
        let (caller) = get_caller_address()
        let (l2account) = mapping_ens_l2account.read(user)
        assert  caller=l2account
    end
    local max = idx_len
    local ret_index = 0
    populate_remove_object_from_land(user, idx_len,idx,ret_index, max)
    return ()
end

func populate_remove_object_from_land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        idx_len : felt,
        idx : felt*,
        ret_index : felt, 
        max : felt
    ):
    alloc_locals
    if ret_index == max:
        return()
    end
    let emptyPhilandObjectInfo : PhilandObjectInfo = PhilandObjectInfo(
        contract_address =   0,
        token_id = Uint256(0,0),
        x_start= 0,
        y_start= 0,
        x_end =  0,
        y_end =  0,
    )
    user_philand_object.write(user, [idx], value = emptyPhilandObjectInfo)
    
    return populate_remove_object_from_land(
        user,
        idx_len - 1,
        idx + 1,
        ret_index + 1, 
        max
        )
end

@external
func deposit_object{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : Uint256,
        contract_address : felt,
        token_id : Uint256) -> (
        success : felt):
    
    alloc_locals
    let (caller_address) = get_caller_address()
    assert_not_zero(caller_address)
    with_attr error_message("caller ens owner dose not match"):
        let (caller) = get_caller_address()
        let (l2account) = mapping_ens_l2account.read(user)
        assert  caller=l2account
    end
    let (phi_contract_address) = get_contract_address()
    let (object_address) = _object_address.read()

    # current stake has to be not deposit
    let (current_state) = user_deposit_object.read(user=user,contract_address=contract_address,token_id=token_id)
    assert (current_state) = FALSE

    let (account_from_balance) = IPhiObject.balance_of(object_address,
        owner=caller_address, token_id=token_id)
    assert_nn_le(1,account_from_balance)

    IPhiObject.safe_transfer_from(
        contract_address=object_address,
        _from=caller_address,
        to=phi_contract_address,
        token_id=token_id,
        amount=1)

    user_deposit_object.write(user=user,contract_address=contract_address,token_id=token_id,value=TRUE)

    return (TRUE)
end

@external
func undeposit_object{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : Uint256,
        contract_address : felt,
        token_id : Uint256) -> (
        success : felt):
    alloc_locals

   let (caller_address) = get_caller_address()
    assert_not_zero(caller_address)

    let (phi_contract_address) = get_contract_address()
    let (object_address) = _object_address.read()

    # current stake has to be deposit
    let (current_state) = user_deposit_object.read(user=user,contract_address=contract_address,token_id=token_id)
    assert (current_state) = TRUE
    
    IPhiObject.safe_transfer_from(
        contract_address=object_address,
        _from=phi_contract_address,
        to=caller_address,
        token_id=token_id,
        amount=1)

    user_deposit_object.write(user=user,contract_address=contract_address,token_id=token_id,value=FALSE)

    return (TRUE)
end

@view 
func check_deposit_state{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }( user : Uint256,
        contract_address : felt,
        token_id : Uint256) -> (
        current_state : felt
    ):
    alloc_locals
    let (current_state) = user_deposit_object.read(user=user,contract_address=contract_address,token_id=token_id)
    return (current_state)
end

@view
func view_philand{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256
    ) -> (
        object_len : felt, object : felt*
    ):
    alloc_locals
    with_attr error_message("philand dose not exist"):
        let (user_flg) = claimed_user.read(user)
        assert  user_flg=TRUE 
    end
    
    let (local max) = user_philand_object_idx.read(user=user)
    let (local object_array : PhilandObjectInfo*) = alloc()
    local ret_index = 0
    populate_view_philand(user,object_array,ret_index, max)

    return (max * 7, object_array)
end

func populate_view_philand{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    user : Uint256,  object_array : PhilandObjectInfo*, ret_index : felt, max : felt):
    alloc_locals
    if ret_index == max:
        return ()
    end

    let (local val0: PhilandObjectInfo) = user_philand_object.read(user=user, idx=ret_index)
    assert object_array[0] = PhilandObjectInfo(
        contract_address= val0.contract_address, 
        token_id=val0.token_id,
        x_start=val0.x_start,
        y_start=val0.y_start,
        x_end=val0.x_end,
        y_end=val0.y_end
        ) 
    populate_view_philand(user, object_array+7,ret_index + 1, max)
    return ()
    
end


@view
func get_user_philand_object{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(user: Uint256, idx:felt) -> (res : PhilandObjectInfo):
    let (res) =  user_philand_object.read(user=user, idx=idx)
    return (res)
end

#############################
##### Other functions #####
#############################
@external
func claim_starter_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256
    ):
    alloc_locals
    let (caller) = get_caller_address()
    with_attr error_message("philand dose not exist"):
        let (user_flg) = claimed_user.read(user)
        assert  user_flg=TRUE 
    end
    with_attr error_message("caller ens owner dose not match"):
        
        let (l2account) = mapping_ens_l2account.read(user)
        assert  caller=l2account
    end
    let (local object) = _object_address.read()
    let (felt_array : felt*) = alloc()
    assert [felt_array] = 1
    assert [felt_array + 1] = 1
    assert [felt_array + 2] = 1
    assert [felt_array + 3] = 1
    assert [felt_array + 4] = 1

    let (uint256_array : Uint256*) = alloc()
    assert [uint256_array] = Uint256(1,0)
    assert [uint256_array + 2] = Uint256(2,0)
    assert [uint256_array + 4] = Uint256(3,0)
    assert [uint256_array + 6] = Uint256(4,0)
    assert [uint256_array + 8] = Uint256(5,0)

    IPhiObject._mint_batch(object,caller, 5,uint256_array,5,felt_array)
    
    return ()
end

#############################
##### Private functions #####
#############################






