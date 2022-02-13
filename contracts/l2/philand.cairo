%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.cairo.common.math import (unsigned_div_rem, assert_nn,
    assert_not_zero, assert_nn_le, assert_le, assert_not_equal,
    split_int)
from starkware.starknet.common.syscalls import (call_contract,
    get_caller_address)
from starkware.cairo.common.uint256 import (Uint256, uint256_le)

##### Description #####
#

#
#######################

@contract_interface
namespace IObject:
    func mint(to_address : felt, value : Uint256):
    end

    func burn(from_address : felt, value : Uint256):
    end

    func allowance(owner : felt, spender : felt) -> (res : Uint256):
    end

    func balanceOf(user : felt) -> (res : Uint256):
    end
end

##### Constants #####
# Width of the simulation grid.


##### Storage #####
@storage_var
func grid(
        grid_x : felt,
        grid_y : felt
    ) -> (
         owner : felt
    ):
end

# For a given game at a given state.
@storage_var
func parcel(
        owner : felt,
        x : felt,
        y : felt
    ) -> (
        object_id : felt
    ):
end

@storage_var
func object_index(
    ) -> (
         res : felt
    ):
end

@storage_var
func object_info(
        object_id : felt
    ) -> (
        token : (felt,Uint256)
    ):
end


# Stores the genesis state hash for a given user.
@storage_var
func object_contract(
        object_id : felt
    ) -> (
        contract_address : felt
    ):
end

@storage_var
func object_tokenid(
        object_id : felt
    ) -> (
        tokenid : Uint256
    ):
end

@storage_var
func object_owner(
        owner : felt,
        object_id : felt       
    ) -> (
        res: felt
    ):
end

@storage_var
func l1_contract() -> (address : felt):
end

##################
@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals

    let (caller) = get_caller_address()
    object_index.write(0)
    return ()
end

##### Public functions #####
# Receive an L1 message. The Sequencer actions this function.
@l1_handler
func create_grid{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt, 
        grid_x : felt, 
        grid_y : felt,
        owner : felt
    ):
    grid.write(grid_x = grid_x, grid_y = grid_y,  value = owner )
    return ()
end

# Sets the initial state of a philand.
@external
func create_philand{
        syscall_ptr : felt*,
        bitwise_ptr : BitwiseBuiltin*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(  
        owner : felt,
        grid_x : felt, grid_y : felt,
        object_0 : felt, object_1 : felt, object_2 : felt, object_3 : felt,
        object_4 : felt, object_5 : felt, object_6 : felt, object_7 : felt,
        object_8 : felt, object_9 : felt, object_10 : felt, object_11 : felt,
        object_12 : felt, object_13 : felt, object_14 : felt, object_15 : felt,
        object_16 : felt, object_17 : felt, object_18 : felt, object_19 : felt,
        object_20 : felt, object_21 : felt, object_22 : felt, object_23 : felt,
        object_24 : felt, object_25 : felt, object_26 : felt, object_27 : felt,
        object_28 : felt, object_29 : felt, object_30 : felt, object_31 : felt,
        object_32 : felt, object_33 : felt, object_34 : felt, object_35 : felt,
        object_36 : felt, object_37 : felt, object_38 : felt, object_39 : felt,
        object_40 : felt, object_41 : felt, object_42 : felt, object_43 : felt,
        object_44 : felt, object_45 : felt, object_46 : felt, object_47 : felt,
        object_48 : felt, object_49 : felt, object_50 : felt, object_51 : felt,
        object_52 : felt, object_53 : felt, object_54 : felt, object_55 : felt,
        object_56 : felt, object_57 : felt, object_58 : felt, object_59 : felt,
        object_60 : felt, object_61 : felt, object_62 : felt, object_63 : felt
    ):
    # Accepts a 64 element list representing the objects.
    alloc_locals
    let (local genesis_state : felt*) = alloc()
    assert genesis_state[0] = object_0
    assert genesis_state[1] = object_1
    assert genesis_state[2] = object_2
    assert genesis_state[3] = object_3
    assert genesis_state[4] = object_4
    assert genesis_state[5] = object_5
    assert genesis_state[6] = object_6
    assert genesis_state[7] = object_7
    assert genesis_state[8] = object_8
    assert genesis_state[9] = object_9
    assert genesis_state[10] = object_10
    assert genesis_state[11] = object_11
    assert genesis_state[12] = object_12
    assert genesis_state[13] = object_13
    assert genesis_state[14] = object_14
    assert genesis_state[15] = object_15
    assert genesis_state[16] = object_16
    assert genesis_state[17] = object_17
    assert genesis_state[18] = object_18
    assert genesis_state[19] = object_19
    assert genesis_state[20] = object_20
    assert genesis_state[21] = object_21
    assert genesis_state[22] = object_22
    assert genesis_state[23] = object_23
    assert genesis_state[24] = object_24
    assert genesis_state[25] = object_25
    assert genesis_state[26] = object_26
    assert genesis_state[27] = object_27
    assert genesis_state[28] = object_28
    assert genesis_state[29] = object_29
    assert genesis_state[30] = object_30
    assert genesis_state[31] = object_31
    assert genesis_state[32] = object_32
    assert genesis_state[33] = object_33
    assert genesis_state[34] = object_34
    assert genesis_state[35] = object_35
    assert genesis_state[36] = object_36
    assert genesis_state[37] = object_37
    assert genesis_state[38] = object_38
    assert genesis_state[39] = object_39
    assert genesis_state[40] = object_40
    assert genesis_state[41] = object_41
    assert genesis_state[42] = object_42
    assert genesis_state[43] = object_43
    assert genesis_state[44] = object_44
    assert genesis_state[45] = object_45
    assert genesis_state[46] = object_46
    assert genesis_state[47] = object_47
    assert genesis_state[48] = object_48
    assert genesis_state[49] = object_49
    assert genesis_state[50] = object_50
    assert genesis_state[51] = object_51
    assert genesis_state[52] = object_52
    assert genesis_state[53] = object_53
    assert genesis_state[54] = object_54
    assert genesis_state[55] = object_55
    assert genesis_state[56] = object_56
    assert genesis_state[57] = object_57
    assert genesis_state[58] = object_58
    assert genesis_state[59] = object_59
    assert genesis_state[60] = object_60
    assert genesis_state[61] = object_61
    assert genesis_state[62] = object_62
    assert genesis_state[63] = object_63

    # let (local caller) = get_caller_address()
    assert_not_zero(owner)
    grid.write(grid_x = grid_x, grid_y = grid_y, value=owner)

    # write philand parcel
    parcel.write(owner=owner, x=0, y=0, value=object_0)
    parcel.write(owner=owner, x=0, y=1, value=object_1)
    parcel.write(owner=owner, x=0, y=2, value=object_2)
    parcel.write(owner=owner, x=0, y=3, value=object_3)
    parcel.write(owner=owner, x=0, y=4, value=object_4)
    parcel.write(owner=owner, x=0, y=5, value=object_5)
    parcel.write(owner=owner, x=0, y=6, value=object_6)
    parcel.write(owner=owner, x=0, y=7, value=object_7)
    parcel.write(owner=owner, x=1, y=0, value=object_8)
    parcel.write(owner=owner, x=1, y=1, value=object_9)
    parcel.write(owner=owner, x=1, y=2, value=object_10)
    parcel.write(owner=owner, x=1, y=3, value=object_11)
    parcel.write(owner=owner, x=1, y=4, value=object_12)
    parcel.write(owner=owner, x=1, y=5, value=object_13)
    parcel.write(owner=owner, x=1, y=6, value=object_14)
    parcel.write(owner=owner, x=1, y=7, value=object_15)
    parcel.write(owner=owner, x=2, y=0, value=object_16)
    parcel.write(owner=owner, x=2, y=1, value=object_17)
    parcel.write(owner=owner, x=2, y=2, value=object_18)
    parcel.write(owner=owner, x=2, y=3, value=object_19)
    parcel.write(owner=owner, x=2, y=4, value=object_20)
    parcel.write(owner=owner, x=2, y=5, value=object_21)
    parcel.write(owner=owner, x=2, y=6, value=object_22)
    parcel.write(owner=owner, x=2, y=7, value=object_23)
    parcel.write(owner=owner, x=3, y=0, value=object_24)
    parcel.write(owner=owner, x=3, y=1, value=object_25)
    parcel.write(owner=owner, x=3, y=2, value=object_26)
    parcel.write(owner=owner, x=3, y=3, value=object_27)
    parcel.write(owner=owner, x=3, y=4, value=object_28)
    parcel.write(owner=owner, x=3, y=5, value=object_29)
    parcel.write(owner=owner, x=3, y=6, value=object_30)
    parcel.write(owner=owner, x=3, y=7, value=object_31)
    parcel.write(owner=owner, x=4, y=0, value=object_32)
    parcel.write(owner=owner, x=4, y=1, value=object_33)
    parcel.write(owner=owner, x=4, y=2, value=object_34)
    parcel.write(owner=owner, x=4, y=3, value=object_35)
    parcel.write(owner=owner, x=4, y=4, value=object_36)
    parcel.write(owner=owner, x=4, y=5, value=object_37)
    parcel.write(owner=owner, x=4, y=6, value=object_38)
    parcel.write(owner=owner, x=4, y=7, value=object_39)
    parcel.write(owner=owner, x=5, y=0, value=object_40)
    parcel.write(owner=owner, x=5, y=1, value=object_41)
    parcel.write(owner=owner, x=5, y=2, value=object_42)
    parcel.write(owner=owner, x=5, y=3, value=object_43)
    parcel.write(owner=owner, x=5, y=4, value=object_44)
    parcel.write(owner=owner, x=5, y=5, value=object_45)
    parcel.write(owner=owner, x=5, y=6, value=object_46)
    parcel.write(owner=owner, x=5, y=7, value=object_47)
    parcel.write(owner=owner, x=6, y=0, value=object_48)
    parcel.write(owner=owner, x=6, y=1, value=object_49)
    parcel.write(owner=owner, x=6, y=2, value=object_50)
    parcel.write(owner=owner, x=6, y=3, value=object_51)
    parcel.write(owner=owner, x=6, y=4, value=object_52)
    parcel.write(owner=owner, x=6, y=5, value=object_53)
    parcel.write(owner=owner, x=6, y=6, value=object_54)
    parcel.write(owner=owner, x=6, y=7, value=object_55)
    parcel.write(owner=owner, x=7, y=0, value=object_56)
    parcel.write(owner=owner, x=7, y=1, value=object_57)
    parcel.write(owner=owner, x=7, y=2, value=object_58)
    parcel.write(owner=owner, x=7, y=3, value=object_59)
    parcel.write(owner=owner, x=7, y=4, value=object_60)
    parcel.write(owner=owner, x=7, y=5, value=object_61)
    parcel.write(owner=owner, x=7, y=6, value=object_62)
    parcel.write(owner=owner, x=7, y=7, value=object_63)

    

    return ()
end


@external
func create_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        contract_address : felt,
        tokenid : Uint256
    ):
    let (current_index) = object_index.read()
    let idx = current_index + 1
    object_index.write(idx)
    object_info.write(idx,(contract_address,tokenid))
    object_contract.write(idx,contract_address)
    object_tokenid.write(idx,tokenid)
    return ()
end

@external
func claim_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        object_id : felt
    ):
    object_owner.write(owner,object_id,1)
    return ()
end

@l1_handler
func claim_l1_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt, 
        owner : felt,
        contract_address : felt,
        tokenid : Uint256
    ):
    create_object(contract_address,tokenid)
    let (current_index) = object_index.read()
    object_owner.write(owner,current_index,1)
    return ()
end

@external
func get_object_index{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    )-> (
        current_index : felt,
    ):
    let (current_index) = object_index.read()
    return (current_index)
end

@external
func write_object_to_parcel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        x : felt,
        y : felt,
        object_id : felt
    ):
    parcel.write(owner, x, y,value=object_id)
    return ()
end


# Returns grid.
@view
func view_grid{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        grid_x : felt,
        grid_y : felt
    ) -> (
        owner : felt
    ):
    return grid.read(grid_x=grid_x,grid_y=grid_y)
end

# Returns a list of objects for the specified generation.
@view
func view_philand{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt
    ) -> (
        object_0 : felt, object_1 : felt, object_2 : felt, object_3 : felt,
        object_4 : felt, object_5 : felt, object_6 : felt, object_7 : felt,
        object_8 : felt, object_9 : felt, object_10 : felt, object_11 : felt,
        object_12 : felt, object_13 : felt, object_14 : felt, object_15 : felt,
        object_16 : felt, object_17 : felt, object_18 : felt, object_19 : felt,
        object_20 : felt, object_21 : felt, object_22 : felt, object_23 : felt,
        object_24 : felt, object_25 : felt, object_26 : felt, object_27 : felt,
        object_28 : felt, object_29 : felt, object_30 : felt, object_31 : felt,
        object_32 : felt, object_33 : felt, object_34 : felt, object_35 : felt,
        object_36 : felt, object_37 : felt, object_38 : felt, object_39 : felt,
        object_40 : felt, object_41 : felt, object_42 : felt, object_43 : felt,
        object_44 : felt, object_45 : felt, object_46 : felt, object_47 : felt,
        object_48 : felt, object_49 : felt, object_50 : felt, object_51 : felt,
        object_52 : felt, object_53 : felt, object_54 : felt, object_55 : felt,
        object_56 : felt, object_57 : felt, object_58 : felt, object_59 : felt,
        object_60 : felt, object_61 : felt, object_62 : felt, object_63 : felt
    ):

    let (object_0) = parcel.read(owner, 0, 0)
    let (object_1) = parcel.read(owner, 0, 1)
    let (object_2) = parcel.read(owner, 0, 2)
    let (object_3) = parcel.read(owner, 0, 3)
    let (object_4) = parcel.read(owner, 0, 4)
    let (object_5) = parcel.read(owner, 0, 5)
    let (object_6) = parcel.read(owner, 0, 6)
    let (object_7) = parcel.read(owner, 0, 7)
    let (object_8) = parcel.read(owner, 1, 0)
    let (object_9) = parcel.read(owner, 1, 1)
    let (object_10) = parcel.read(owner, 1, 2)
    let (object_11) = parcel.read(owner, 1, 3)
    let (object_12) = parcel.read(owner, 1, 4)
    let (object_13) = parcel.read(owner, 1, 5)
    let (object_14) = parcel.read(owner, 1, 6)
    let (object_15) = parcel.read(owner, 1, 7)
    let (object_16) = parcel.read(owner, 2, 0)
    let (object_17) = parcel.read(owner, 2, 1)
    let (object_18) = parcel.read(owner, 2, 2)
    let (object_19) = parcel.read(owner, 2, 3)
    let (object_20) = parcel.read(owner, 2, 4)
    let (object_21) = parcel.read(owner, 2, 5)
    let (object_22) = parcel.read(owner, 2, 6)
    let (object_23) = parcel.read(owner, 2, 7)
    let (object_24) = parcel.read(owner, 3, 0)
    let (object_25) = parcel.read(owner, 3, 1)
    let (object_26) = parcel.read(owner, 3, 2)
    let (object_27) = parcel.read(owner, 3, 3)
    let (object_28) = parcel.read(owner, 3, 4)
    let (object_29) = parcel.read(owner, 3, 5)
    let (object_30) = parcel.read(owner, 3, 6)
    let (object_31) = parcel.read(owner, 3, 7)
    let (object_32) = parcel.read(owner, 4, 0)
    let (object_33) = parcel.read(owner, 4, 1)
    let (object_34) = parcel.read(owner, 4, 2)
    let (object_35) = parcel.read(owner, 4, 3)
    let (object_36) = parcel.read(owner, 4, 4)
    let (object_37) = parcel.read(owner, 4, 5)
    let (object_38) = parcel.read(owner, 4, 6)
    let (object_39) = parcel.read(owner, 4, 7)
    let (object_40) = parcel.read(owner, 5, 0)
    let (object_41) = parcel.read(owner, 5, 1)
    let (object_42) = parcel.read(owner, 5, 2)
    let (object_43) = parcel.read(owner, 5, 3)
    let (object_44) = parcel.read(owner, 5, 4)
    let (object_45) = parcel.read(owner, 5, 5)
    let (object_46) = parcel.read(owner, 5, 6)
    let (object_47) = parcel.read(owner, 5, 7)
    let (object_48) = parcel.read(owner, 6, 0)
    let (object_49) = parcel.read(owner, 6, 1)
    let (object_50) = parcel.read(owner, 6, 2)
    let (object_51) = parcel.read(owner, 6, 3)
    let (object_52) = parcel.read(owner, 6, 4)
    let (object_53) = parcel.read(owner, 6, 5)
    let (object_54) = parcel.read(owner, 6, 6)
    let (object_55) = parcel.read(owner, 6, 7)
    let (object_56) = parcel.read(owner, 7, 0)
    let (object_57) = parcel.read(owner, 7, 1)
    let (object_58) = parcel.read(owner, 7, 2)
    let (object_59) = parcel.read(owner, 7, 3)
    let (object_60) = parcel.read(owner, 7, 4)
    let (object_61) = parcel.read(owner, 7, 5)
    let (object_62) = parcel.read(owner, 7, 6)
    let (object_63) = parcel.read(owner, 7, 7)
    return (object_0, object_1, object_2, object_3, object_4, object_5,
        object_6, object_7, object_8, object_9, object_10, object_11,
        object_12, object_13, object_14, object_15, object_16, object_17,
        object_18, object_19, object_20, object_21, object_22, object_23,
        object_24, object_25, object_26, object_27, object_28, object_29,
        object_30, object_31, object_32, object_33, object_34, object_35,
        object_36, object_37, object_38, object_39, object_40, object_41,
        object_42, object_43, object_44, object_45, object_46, object_47,
        object_48, object_49, object_50, object_51, object_52, object_53,
        object_54, object_55, object_56, object_57, object_58, object_59,
        object_60, object_61,object_62, object_63)
end

# Returns parcel object data (contract_address, tokenid).
@view
func view_parcel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        x : felt,
        y : felt
    ) -> (
       object_id : felt
    ):
    let (object_id) = parcel.read(owner, x, y)
    return (object_id)
end

# Returns parcel object data (contract_address, tokenid).
@view
func view_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        object_id : felt
    ) -> (
        contract_address : felt,
        tokenid : Uint256
    ):
    let (contract_address) = object_contract.read(object_id)
    let (tokenid) = object_tokenid.read(object_id)
    return (contract_address, tokenid)
end

#############################
##### Private functions #####
#############################

