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
    get_caller_address,get_block_timestamp,get_contract_address)
from starkware.cairo.common.uint256 import (Uint256, uint256_le)

##### Description #####
#
# Management of philand's map contract
#
#######################


@contract_interface
namespace IObject:
    
    func _mint(to : felt, token_id : Uint256, amount : felt):
    end

    func _mint_batch(to : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt, amounts : felt*):
    end

    func _burn(_from : felt, token_id : felt, amount : felt):
    end

    func balanceOf(user : felt, token_id : felt) -> (res : felt):
    end

    func setTokenURI(token_uri_len : felt, token_uri : felt*,token_id : Uint256):
    end

end

##### Constants #####
# Width of the simulation grid.


##### Event #####
@event
func mint_object_event(
        object_address : felt, to : felt, token_id : Uint256, amount : felt):
end

##### Storage #####


struct Tokendata:
    member contract_address : felt
    member token_id : Uint256
end

struct Maplink:
    member contract_address : felt
    member target_owner : Uint256
end

# For a given game at a given state.
@storage_var
func parcel(
        owner : Uint256,
        x : felt,
        y : felt
    ) -> (
        object : Tokendata
    ):
end


@storage_var
func parcel_link(
        owner : Uint256,
        x : felt,
        y : felt
    ) -> (
        link : Maplink
    ):
end


struct Spawnlink:
    member x : felt
    member y : felt
end


struct SettingEnum:
    member created_at : felt
    member updated_at : felt
    member land_type : felt
    member spawn_link : Spawnlink
    member text_records : felt
end


@storage_var
func _settings(owner: Uint256, setting_index : felt) -> (res : felt):
end


@storage_var
func _setting_link(owner: Uint256, setting_index : felt) -> (res : Spawnlink):
end


@storage_var
func number_of_philand(
    ) -> (
         res : felt
    ):
end

# @storage_var
# func object_index(
#     ) -> (
#          res : felt
#     ):
# end



# @storage_var
# func object_info(
#         object_id : felt
#     ) -> (
#         res : Tokendata
#     ):
# end

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
    token_uri_len : felt,
    token_uri : felt*
    ):
    alloc_locals

    let (caller) = get_caller_address()
    number_of_philand.write(0)
    _object_address.write(object_address)
    _l1_philand_address.write(l1_philand_address)

    create_l2_object(contract_address=object_address,token_id=Uint256(1,0),token_uri_len=token_uri_len, token_uri=token_uri,)
    return ()
end

##### Public functions #####
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
        owner_low : felt,
        owner_high : felt
    ):
    # Accepts a 64 element list representing the objects.
    alloc_locals
    let owner : Uint256 = Uint256(owner_low,owner_high)
    # assert_not_zero(owner)
    
    let token_data = Tokendata(
        contract_address =  0,
        token_id = Uint256(0,0)
    )


    let map_link = Maplink(
        contract_address =  0,
        target_owner = Uint256(0,0)
    )

    # write philand parcel
    parcel.write(owner=owner, x=0, y=0, value=token_data)
    parcel.write(owner=owner, x=0, y=1, value=token_data)
    parcel.write(owner=owner, x=0, y=2, value=token_data)
    parcel.write(owner=owner, x=0, y=3, value=token_data)
    parcel.write(owner=owner, x=0, y=4, value=token_data)
    parcel.write(owner=owner, x=0, y=5, value=token_data)
    parcel.write(owner=owner, x=0, y=6, value=token_data)
    parcel.write(owner=owner, x=0, y=7, value=token_data)
    parcel.write(owner=owner, x=1, y=0, value=token_data)
    parcel.write(owner=owner, x=1, y=1, value=token_data)
    parcel.write(owner=owner, x=1, y=2, value=token_data)
    parcel.write(owner=owner, x=1, y=3, value=token_data)
    parcel.write(owner=owner, x=1, y=4, value=token_data)
    parcel.write(owner=owner, x=1, y=5, value=token_data)
    parcel.write(owner=owner, x=1, y=6, value=token_data)
    parcel.write(owner=owner, x=1, y=7, value=token_data)
    parcel.write(owner=owner, x=2, y=0, value=token_data)
    parcel.write(owner=owner, x=2, y=1, value=token_data)
    parcel.write(owner=owner, x=2, y=2, value=token_data)
    parcel.write(owner=owner, x=2, y=3, value=token_data)
    parcel.write(owner=owner, x=2, y=4, value=token_data)
    parcel.write(owner=owner, x=2, y=5, value=token_data)
    parcel.write(owner=owner, x=2, y=6, value=token_data)
    parcel.write(owner=owner, x=2, y=7, value=token_data)
    parcel.write(owner=owner, x=3, y=0, value=token_data)
    parcel.write(owner=owner, x=3, y=1, value=token_data)
    parcel.write(owner=owner, x=3, y=2, value=token_data)
    parcel.write(owner=owner, x=3, y=3, value=token_data)
    parcel.write(owner=owner, x=3, y=4, value=token_data)
    parcel.write(owner=owner, x=3, y=5, value=token_data)
    parcel.write(owner=owner, x=3, y=6, value=token_data)
    parcel.write(owner=owner, x=3, y=7, value=token_data)
    parcel.write(owner=owner, x=4, y=0, value=token_data)
    parcel.write(owner=owner, x=4, y=1, value=token_data)
    parcel.write(owner=owner, x=4, y=2, value=token_data)
    parcel.write(owner=owner, x=4, y=3, value=token_data)
    parcel.write(owner=owner, x=4, y=4, value=token_data)
    parcel.write(owner=owner, x=4, y=5, value=token_data)
    parcel.write(owner=owner, x=4, y=6, value=token_data)
    parcel.write(owner=owner, x=4, y=7, value=token_data)
    parcel.write(owner=owner, x=5, y=0, value=token_data)
    parcel.write(owner=owner, x=5, y=1, value=token_data)
    parcel.write(owner=owner, x=5, y=2, value=token_data)
    parcel.write(owner=owner, x=5, y=3, value=token_data)
    parcel.write(owner=owner, x=5, y=4, value=token_data)
    parcel.write(owner=owner, x=5, y=5, value=token_data)
    parcel.write(owner=owner, x=5, y=6, value=token_data)
    parcel.write(owner=owner, x=5, y=7, value=token_data)
    parcel.write(owner=owner, x=6, y=0, value=token_data)
    parcel.write(owner=owner, x=6, y=1, value=token_data)
    parcel.write(owner=owner, x=6, y=2, value=token_data)
    parcel.write(owner=owner, x=6, y=3, value=token_data)
    parcel.write(owner=owner, x=6, y=4, value=token_data)
    parcel.write(owner=owner, x=6, y=5, value=token_data)
    parcel.write(owner=owner, x=6, y=6, value=token_data)
    parcel.write(owner=owner, x=6, y=7, value=token_data)
    parcel.write(owner=owner, x=7, y=0, value=token_data)
    parcel.write(owner=owner, x=7, y=1, value=token_data)
    parcel.write(owner=owner, x=7, y=2, value=token_data)
    parcel.write(owner=owner, x=7, y=3, value=token_data)
    parcel.write(owner=owner, x=7, y=4, value=token_data)
    parcel.write(owner=owner, x=7, y=5, value=token_data)
    parcel.write(owner=owner, x=7, y=6, value=token_data)
    parcel.write(owner=owner, x=7, y=7, value=token_data)

    parcel_link.write(owner=owner, x=0, y=0, value=map_link)
    parcel_link.write(owner=owner, x=0, y=1, value=map_link)
    parcel_link.write(owner=owner, x=0, y=2, value=map_link)
    parcel_link.write(owner=owner, x=0, y=3, value=map_link)
    parcel_link.write(owner=owner, x=0, y=4, value=map_link)
    parcel_link.write(owner=owner, x=0, y=5, value=map_link)
    parcel_link.write(owner=owner, x=0, y=6, value=map_link)
    parcel_link.write(owner=owner, x=0, y=7, value=map_link)
    parcel_link.write(owner=owner, x=1, y=0, value=map_link)
    parcel_link.write(owner=owner, x=1, y=1, value=map_link)
    parcel_link.write(owner=owner, x=1, y=2, value=map_link)
    parcel_link.write(owner=owner, x=1, y=3, value=map_link)
    parcel_link.write(owner=owner, x=1, y=4, value=map_link)
    parcel_link.write(owner=owner, x=1, y=5, value=map_link)
    parcel_link.write(owner=owner, x=1, y=6, value=map_link)
    parcel_link.write(owner=owner, x=1, y=7, value=map_link)
    parcel_link.write(owner=owner, x=2, y=0, value=map_link)
    parcel_link.write(owner=owner, x=2, y=1, value=map_link)
    parcel_link.write(owner=owner, x=2, y=2, value=map_link)
    parcel_link.write(owner=owner, x=2, y=3, value=map_link)
    parcel_link.write(owner=owner, x=2, y=4, value=map_link)
    parcel_link.write(owner=owner, x=2, y=5, value=map_link)
    parcel_link.write(owner=owner, x=2, y=6, value=map_link)
    parcel_link.write(owner=owner, x=2, y=7, value=map_link)
    parcel_link.write(owner=owner, x=3, y=0, value=map_link)
    parcel_link.write(owner=owner, x=3, y=1, value=map_link)
    parcel_link.write(owner=owner, x=3, y=2, value=map_link)
    parcel_link.write(owner=owner, x=3, y=3, value=map_link)
    parcel_link.write(owner=owner, x=3, y=4, value=map_link)
    parcel_link.write(owner=owner, x=3, y=5, value=map_link)
    parcel_link.write(owner=owner, x=3, y=6, value=map_link)
    parcel_link.write(owner=owner, x=3, y=7, value=map_link)
    parcel_link.write(owner=owner, x=4, y=0, value=map_link)
    parcel_link.write(owner=owner, x=4, y=1, value=map_link)
    parcel_link.write(owner=owner, x=4, y=2, value=map_link)
    parcel_link.write(owner=owner, x=4, y=3, value=map_link)
    parcel_link.write(owner=owner, x=4, y=4, value=map_link)
    parcel_link.write(owner=owner, x=4, y=5, value=map_link)
    parcel_link.write(owner=owner, x=4, y=6, value=map_link)
    parcel_link.write(owner=owner, x=4, y=7, value=map_link)
    parcel_link.write(owner=owner, x=5, y=0, value=map_link)
    parcel_link.write(owner=owner, x=5, y=1, value=map_link)
    parcel_link.write(owner=owner, x=5, y=2, value=map_link)
    parcel_link.write(owner=owner, x=5, y=3, value=map_link)
    parcel_link.write(owner=owner, x=5, y=4, value=map_link)
    parcel_link.write(owner=owner, x=5, y=5, value=map_link)
    parcel_link.write(owner=owner, x=5, y=6, value=map_link)
    parcel_link.write(owner=owner, x=5, y=7, value=map_link)
    parcel_link.write(owner=owner, x=6, y=0, value=map_link)
    parcel_link.write(owner=owner, x=6, y=1, value=map_link)
    parcel_link.write(owner=owner, x=6, y=2, value=map_link)
    parcel_link.write(owner=owner, x=6, y=3, value=map_link)
    parcel_link.write(owner=owner, x=6, y=4, value=map_link)
    parcel_link.write(owner=owner, x=6, y=5, value=map_link)
    parcel_link.write(owner=owner, x=6, y=6, value=map_link)
    parcel_link.write(owner=owner, x=6, y=7, value=map_link)
    parcel_link.write(owner=owner, x=7, y=0, value=map_link)
    parcel_link.write(owner=owner, x=7, y=1, value=map_link)
    parcel_link.write(owner=owner, x=7, y=2, value=map_link)
    parcel_link.write(owner=owner, x=7, y=3, value=map_link)
    parcel_link.write(owner=owner, x=7, y=4, value=map_link)
    parcel_link.write(owner=owner, x=7, y=5, value=map_link)
    parcel_link.write(owner=owner, x=7, y=6, value=map_link)
    parcel_link.write(owner=owner, x=7, y=7, value=map_link)
    # create init setting
    let (block_timestamp) = get_block_timestamp()
    _settings.write(owner, SettingEnum.created_at,block_timestamp)
    _settings.write(owner, SettingEnum.updated_at,block_timestamp)
    _settings.write(owner, SettingEnum.land_type,0)
    

    local spawn_link : Spawnlink = Spawnlink(
        x =  0,
        y = 0
    )
    _setting_link.write(owner,SettingEnum.spawn_link,spawn_link)
    _settings.write(owner, SettingEnum.text_records,value=0)

    let (res) = number_of_philand.read()
    let index = res +1
    number_of_philand.write(index)
    return ()
end

# set new land type
@external
func write_setting_landtype{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner : Uint256,land_type : felt):
    _settings.write(owner, SettingEnum.land_type,land_type)
    return ()
end

@external
func write_setting_spawn_link{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner : Uint256, spawn_link : Spawnlink):
    _setting_link.write(owner, SettingEnum.spawn_link,spawn_link)
    return ()
end

# Create New lint to philand at specific parcel
@external
func write_link{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner : Uint256, x : felt, y : felt, contract_address : felt, target_owner : Uint256):
    alloc_locals    
    
    let map_link = Maplink(
        contract_address =  contract_address,
        target_owner = target_owner
    )
    parcel_link.write(owner,x,y,map_link)
    
    return ()
end

@external
func claim_starter_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : Uint256,
        receive_address : felt
    ):
    # check valid recipient
    # with_attr error_message("Object/invalid-recipient"):
    # #   assert_not_zero(account)
    #   let (caller_address) = get_caller_address()
    #   assert_not_zero(caller_address)
    # end

    # # todo already claimed
    # with_attr error_message("Object/invalid-nft"):
    # #   assert_not_zero(num)
    # end

    # with_attr error_message("Object/invalid-token_id"):
    #   let (nftOwner) = IObject.ownerOf(token_id)
    # end
    alloc_locals
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

    IObject._mint_batch(object,receive_address, 5,uint256_array,5,felt_array)
    
    return ()
end


@l1_handler
func claim_l1_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt,
        owner : Uint256,
        contract_address : felt,
        token_id : Uint256
    ):
    create_l1nft_object(contract_address,token_id)
    
   
    return ()
end




@l1_handler
func claim_l2_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt,
        owner_low : felt,
        owner_high : felt,
        receive_address : felt,
        token_id_low : felt,
        token_id_high : felt
    ):
    alloc_locals

    # todo setowner=>L2addresss

    let (object_address) = _object_address.read()
    let newTokendata = Tokendata(
                        contract_address = object_address,
                        token_id=Uint256(token_id_low,token_id_high)
                        )

    
    IObject._mint(object_address,receive_address,Uint256(token_id_low,token_id_high),1)
    mint_object_event.emit(object_address=object_address,to=receive_address,token_id=Uint256(token_id_low,token_id_high),amount=1)
    return ()
end



# Write object id to parcel
@external
func write_object_to_parcel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        x : felt,
        y : felt,
        owner : Uint256,
        contract_address : felt,
        token_id : Uint256
    ):
    let token_data = Tokendata(
        contract_address =  contract_address,
        token_id = token_id
    )
    parcel.write(owner, x, y,value=token_data)
    return ()
end

# Write object id to parcel (batch operation)
@external
func batch_write_object_to_parcel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        x_len : felt, 
        x : felt*,
        y_len : felt,
        y : felt*,
        owner : Uint256,
        token_data_len : felt,
        token_data : Tokendata*
    ):
    assert x_len = y_len
    assert x_len = token_data_len
    if x_len == 0:
        return ()
    end
    parcel.write(owner, [x], [y],value=[token_data])
    return batch_write_object_to_parcel(
        x_len = x_len - 1,
        x = x + 1,
        y_len = y_len - 1,
        y = y + 1,
        owner = owner,
        token_data_len = token_data_len - 1,
        token_data = token_data + 3)
end

# Returns a list of objects for the specified generation.
@view
func view_philand{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : Uint256
    ) -> (
        object_0 : Tokendata, object_1 : Tokendata, object_2 : Tokendata, object_3 : Tokendata,
        object_4 : Tokendata, object_5 : Tokendata, object_6 : Tokendata, object_7 : Tokendata,
        object_8 : Tokendata, object_9 : Tokendata, object_10 : Tokendata, object_11 : Tokendata,
        object_12 : Tokendata, object_13 : Tokendata, object_14 : Tokendata, object_15 : Tokendata,
        object_16 : Tokendata, object_17 : Tokendata, object_18 : Tokendata, object_19 : Tokendata,
        object_20 : Tokendata, object_21 : Tokendata, object_22 : Tokendata, object_23 : Tokendata,
        object_24 : Tokendata, object_25 : Tokendata, object_26 : Tokendata, object_27 : Tokendata,
        object_28 : Tokendata, object_29 : Tokendata, object_30 : Tokendata, object_31 : Tokendata,
        object_32 : Tokendata, object_33 : Tokendata, object_34 : Tokendata, object_35 : Tokendata,
        object_36 : Tokendata, object_37 : Tokendata, object_38 : Tokendata, object_39 : Tokendata,
        object_40 : Tokendata, object_41 : Tokendata, object_42 : Tokendata, object_43 : Tokendata,
        object_44 : Tokendata, object_45 : Tokendata, object_46 : Tokendata, object_47 : Tokendata,
        object_48 : Tokendata, object_49 : Tokendata, object_50 : Tokendata, object_51 : Tokendata,
        object_52 : Tokendata, object_53 : Tokendata, object_54 : Tokendata, object_55 : Tokendata,
        object_56 : Tokendata, object_57 : Tokendata, object_58 : Tokendata, object_59 : Tokendata,
        object_60 : Tokendata, object_61 : Tokendata, object_62 : Tokendata, object_63 : Tokendata
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
        object_60, object_61, object_62, object_63)
end

# Returns parcel object data (contract_address, token_id).
@view
func view_parcel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : Uint256,
        x : felt,
        y : felt
    ) -> (
        contract_address : felt,
        token_id : Uint256,
        link : Maplink
    ):
    let (object) = parcel.read(owner, x, y)
    let (link) = parcel_link.read(owner, x, y)
    return (object.contract_address, object.token_id,link)
end

@view
func view_links{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : Uint256
    ) -> (
        link_0 : Maplink, link_1 : Maplink, link_2 : Maplink, link_3 : Maplink,
        link_4 : Maplink, link_5 : Maplink, link_6 : Maplink, link_7 : Maplink,
        link_8 : Maplink, link_9 : Maplink, link_10 : Maplink, link_11 : Maplink,
        link_12 : Maplink, link_13 : Maplink, link_14 : Maplink, link_15 : Maplink,
        link_16 : Maplink, link_17 : Maplink, link_18 : Maplink, link_19 : Maplink,
        link_20 : Maplink, link_21 : Maplink, link_22 : Maplink, link_23 : Maplink,
        link_24 : Maplink, link_25 : Maplink, link_26 : Maplink, link_27 : Maplink,
        link_28 : Maplink, link_29 : Maplink, link_30 : Maplink, link_31 : Maplink,
        link_32 : Maplink, link_33 : Maplink, link_34 : Maplink, link_35 : Maplink,
        link_36 : Maplink, link_37 : Maplink, link_38 : Maplink, link_39 : Maplink,
        link_40 : Maplink, link_41 : Maplink, link_42 : Maplink, link_43 : Maplink,
        link_44 : Maplink, link_45 : Maplink, link_46 : Maplink, link_47 : Maplink,
        link_48 : Maplink, link_49 : Maplink, link_50 : Maplink, link_51 : Maplink,
        link_52 : Maplink, link_53 : Maplink, link_54 : Maplink, link_55 : Maplink,
        link_56 : Maplink, link_57 : Maplink, link_58 : Maplink, link_59 : Maplink,
        link_60 : Maplink, link_61 : Maplink, link_62 : Maplink, link_63 : Maplink
    ):

    let (link_0) = parcel_link.read(owner, 0, 0)
    let (link_1) = parcel_link.read(owner, 0, 1)
    let (link_2) = parcel_link.read(owner, 0, 2)
    let (link_3) = parcel_link.read(owner, 0, 3)
    let (link_4) = parcel_link.read(owner, 0, 4)
    let (link_5) = parcel_link.read(owner, 0, 5)
    let (link_6) = parcel_link.read(owner, 0, 6)
    let (link_7) = parcel_link.read(owner, 0, 7)
    let (link_8) = parcel_link.read(owner, 1, 0)
    let (link_9) = parcel_link.read(owner, 1, 1)
    let (link_10) = parcel_link.read(owner, 1, 2)
    let (link_11) = parcel_link.read(owner, 1, 3)
    let (link_12) = parcel_link.read(owner, 1, 4)
    let (link_13) = parcel_link.read(owner, 1, 5)
    let (link_14) = parcel_link.read(owner, 1, 6)
    let (link_15) = parcel_link.read(owner, 1, 7)
    let (link_16) = parcel_link.read(owner, 2, 0)
    let (link_17) = parcel_link.read(owner, 2, 1)
    let (link_18) = parcel_link.read(owner, 2, 2)
    let (link_19) = parcel_link.read(owner, 2, 3)
    let (link_20) = parcel_link.read(owner, 2, 4)
    let (link_21) = parcel_link.read(owner, 2, 5)
    let (link_22) = parcel_link.read(owner, 2, 6)
    let (link_23) = parcel_link.read(owner, 2, 7)
    let (link_24) = parcel_link.read(owner, 3, 0)
    let (link_25) = parcel_link.read(owner, 3, 1)
    let (link_26) = parcel_link.read(owner, 3, 2)
    let (link_27) = parcel_link.read(owner, 3, 3)
    let (link_28) = parcel_link.read(owner, 3, 4)
    let (link_29) = parcel_link.read(owner, 3, 5)
    let (link_30) = parcel_link.read(owner, 3, 6)
    let (link_31) = parcel_link.read(owner, 3, 7)
    let (link_32) = parcel_link.read(owner, 4, 0)
    let (link_33) = parcel_link.read(owner, 4, 1)
    let (link_34) = parcel_link.read(owner, 4, 2)
    let (link_35) = parcel_link.read(owner, 4, 3)
    let (link_36) = parcel_link.read(owner, 4, 4)
    let (link_37) = parcel_link.read(owner, 4, 5)
    let (link_38) = parcel_link.read(owner, 4, 6)
    let (link_39) = parcel_link.read(owner, 4, 7)
    let (link_40) = parcel_link.read(owner, 5, 0)
    let (link_41) = parcel_link.read(owner, 5, 1)
    let (link_42) = parcel_link.read(owner, 5, 2)
    let (link_43) = parcel_link.read(owner, 5, 3)
    let (link_44) = parcel_link.read(owner, 5, 4)
    let (link_45) = parcel_link.read(owner, 5, 5)
    let (link_46) = parcel_link.read(owner, 5, 6)
    let (link_47) = parcel_link.read(owner, 5, 7)
    let (link_48) = parcel_link.read(owner, 6, 0)
    let (link_49) = parcel_link.read(owner, 6, 1)
    let (link_50) = parcel_link.read(owner, 6, 2)
    let (link_51) = parcel_link.read(owner, 6, 3)
    let (link_52) = parcel_link.read(owner, 6, 4)
    let (link_53) = parcel_link.read(owner, 6, 5)
    let (link_54) = parcel_link.read(owner, 6, 6)
    let (link_55) = parcel_link.read(owner, 6, 7)
    let (link_56) = parcel_link.read(owner, 7, 0)
    let (link_57) = parcel_link.read(owner, 7, 1)
    let (link_58) = parcel_link.read(owner, 7, 2)
    let (link_59) = parcel_link.read(owner, 7, 3)
    let (link_60) = parcel_link.read(owner, 7, 4)
    let (link_61) = parcel_link.read(owner, 7, 5)
    let (link_62) = parcel_link.read(owner, 7, 6)
    let (link_63) = parcel_link.read(owner, 7, 7)
    return (link_0, link_1, link_2, link_3, link_4, link_5,
        link_6, link_7, link_8, link_9, link_10, link_11,
        link_12, link_13, link_14, link_15, link_16, link_17,
        link_18, link_19, link_20, link_21, link_22, link_23,
        link_24, link_25, link_26, link_27, link_28, link_29,
        link_30, link_31, link_32, link_33, link_34, link_35,
        link_36, link_37, link_38, link_39, link_40, link_41,
        link_42, link_43, link_44, link_45, link_46, link_47,
        link_48, link_49, link_50, link_51, link_52, link_53,
        link_54, link_55, link_56, link_57, link_58, link_59,
        link_60, link_61,link_62, link_63)
end

# Returns philand setting data (created,update,type).
@view
func view_setting{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner :Uint256) -> (created_at : felt,updated_at : felt,land_type : felt, spawn_link : Spawnlink,text_records :felt):
    let (created_at) = _settings.read(owner, SettingEnum.created_at)
    let (updated_at) = _settings.read(owner, SettingEnum.updated_at)
    let (land_type) = _settings.read(owner, SettingEnum.land_type)
    let (spawn_link) = _setting_link.read(owner, SettingEnum.spawn_link)
    let (text_records)=_settings.read(owner, SettingEnum.text_records)
    return (created_at,updated_at,land_type,spawn_link,text_records)
end


@view
func view_number_of_philand{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (
        res : felt,
        
    ):
    let (res) = number_of_philand.read()
    return (res)
end

# should change view =>external

#############################
##### Private functions #####
#############################
func create_l1nft_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        contract_address : felt,
        token_id : Uint256
    ):


    return ()
end

@external
func create_l2_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        contract_address : felt,
        token_id : Uint256,
        token_uri_len : felt,
        token_uri : felt*
    ):
    alloc_locals
    let (object) = _object_address.read()
    IObject.setTokenURI(object,token_uri_len, token_uri, token_id)

    return ()
end

