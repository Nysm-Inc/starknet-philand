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

from contracts.l2.utils.constants import FALSE, TRUE

##### Description #####
#
# Management of philand's map contract
#
#######################


##### Interfacess #####
from contracts.l2.interfaces.IPhiObject import IPhiObject 


##### Constants #####


##### Event #####
@event
func mint_object_event(
        object_address : felt, to : felt, token_id : Uint256, amount : felt):
end


##### Struct #####
struct Tokendata:
    member contract_address : felt
    member token_id : Uint256
end

struct Maplink:
    member contract_address : felt
    member target_user : Uint256
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

struct Coordinates:
    member x : felt
    member y : felt
    member z : felt
end

# struct PhilandObjectInfo:
#     member contract_address : felt
#     member token_id : Uint256
#     member x_start : felt
#     member x_size : felt
#     member y_start : felt
#     member y_size : felt
#     member z_start : felt
#     member z_size : felt
# end

struct ObjectSize:
    member x : felt
    member y : felt
    member z : felt
end

##### Storage #####
@storage_var
func _user_philand_object_idx(user: Uint256) -> (res : felt):
end

@storage_var
func _user_philand_object(user: Uint256, idx: felt) -> (res : PhilandObjectInfo):
end

# For a given game at a given state.
@storage_var
func _settings(user: Uint256, setting_index : felt) -> (res : felt):
end


@storage_var
func _setting_link(user: Uint256, setting_index : felt) -> (res : Spawnlink):
end

@storage_var
func claimed_user(
        user : Uint256,
    ) -> (
        res : felt
    ):
end

@storage_var
func use_block(
        user : Uint256,
        x : felt,
        y : felt,
        
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
    alloc_locals

    let (caller) = get_caller_address()
    number_of_philand.write(0)
    _object_address.write(object_address)
    _l1_philand_address.write(l1_philand_address)

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
        user_low : felt,
        user_high : felt
    ):
    # Accepts a 64 element list representing the objects.
    alloc_locals
    let user : Uint256 = Uint256(user_low,user_high)
    # assert_not_zero(user)

    let token_data = Tokendata(
        contract_address =  0,
        token_id = Uint256(0,0)
    )

    let map_link = Maplink(
        contract_address =  0,
        target_user = Uint256(0,0)
    )
   
    # create init setting
    let (block_timestamp) = get_block_timestamp()
    _settings.write(user, SettingEnum.created_at,block_timestamp)
    _settings.write(user, SettingEnum.updated_at,block_timestamp)
    _settings.write(user, SettingEnum.land_type,0)
    claimed_user.write(user,TRUE)

    local spawn_link : Spawnlink = Spawnlink(
        x = 0,
        y = 0
    )
    _setting_link.write(user,SettingEnum.spawn_link,spawn_link)
    _settings.write(user, SettingEnum.text_records,value=0)

    let (res) = number_of_philand.read()
    let index = res + 1
    number_of_philand.write(index)
    return ()
end

# set new land type
@external
func write_setting_landtype{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(user : Uint256,land_type : felt):
    _settings.write(user, SettingEnum.land_type,land_type)
    return ()
end

@external
func write_setting_spawn_link{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(user : Uint256, spawn_link : Spawnlink):
    _setting_link.write(user, SettingEnum.spawn_link,spawn_link)
    return ()
end

# Create New lint to philand at specific parcel
@external
func write_link{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(user : Uint256, x : felt, y : felt, contract_address : felt, target_user : Uint256):
    alloc_locals    
    
    let map_link = Maplink(
        contract_address =  contract_address,
        target_user = target_user
    )

    return ()
end

@external
func claim_starter_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        receive_address : felt
    ):
   
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

    IPhiObject._mint_batch(object,receive_address, 5,uint256_array,5,felt_array)
    
    return ()
end

@l1_handler
func claim_l2_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt,
        user_low : felt,
        user_high : felt,
        receive_address : felt,
        token_id_low : felt,
        token_id_high : felt
    ):
    alloc_locals

    let (object_address) = _object_address.read()
    let newTokendata = Tokendata(
                        contract_address = object_address,
                        token_id=Uint256(token_id_low,token_id_high)
                        )

    IPhiObject._mint(object_address,receive_address,Uint256(token_id_low,token_id_high),1)
    mint_object_event.emit(object_address=object_address,to=receive_address,token_id=Uint256(token_id_low,token_id_high),amount=1)
    return ()
end


# Write object id to parcel
@external
func write_object_to_land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        x_start : felt,
        y_start : felt,
        z_start : felt,
        user : Uint256,
        contract_address : felt,
        token_id : Uint256
    ):
    let size : ObjectSize = IPhiObject.get_size(contract_address,token_id)
    let philandObjectInfo : PhilandObjectInfo = PhilandObjectInfo(
        contract_address =  contract_address,
        token_id = token_id,
        x_start=x_start,
        x_size =size.x,
        y_start=y_start,
        y_size =size.y,
        z_start=z_start,
        z_size =size.z
    )
    let (idx)=_user_philand_object_idx.read(user=user)
    _user_philand_object.write(user=user, idx=idx + 1, value = philandObjectInfo)
    
    block_write(user=user,x_len=size.x,x=x_start,y_len=size.y,y=y_start)
    return ()
end

# Write object id to parcel (batch operation)
@external
func block_write{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        x_len : felt, 
        x : felt,
        y_len : felt,
        y : felt,
    ):
    # assert x_len = y_len

    if y_len == 0:
        return ()
    end
    use_block.write(user, [x], [y], value=1)
    block_xwrite(
        user = user,
        x_len = x_len - 1,
        x = x + 1,
        y_len = y_len,
        y = y,
        )
    return block_write(
        user = user,
        x_len = x_len,
        x = x,
        y_len = y_len - 1,
        y = y + 1,
        )
end

@external
func block_xwrite{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256,
        x_len : felt, 
        x : felt,
        y_len : felt,
        y : felt,
    ):
    # assert x_len = y_len
    if x_len == 0:
        return ()
    end

    use_block.write(user, [x], [y], value=1)
    return block_xwrite(
        user = user,
        x_len = x_len - 1,
        x = x + 1,
        y_len = y_len,
        y = y,
        )
end

# Returns a list of objects for the specified generation.
@view
func view_philand{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256
    ) -> (
        coordinates_len : felt, coordinates : felt*, size_len : felt, size : felt*
    ):
    alloc_locals
    with_attr error_message("philand dose not exist"):
        let (user_flg) = claimed_user.read(user)
        assert  user_flg=TRUE 
    end
    let (local max) = _user_philand_object_idx.read(user=user)
    let (local tokendata_array : felt*) = alloc()
    let (local coordinates_array : felt*) = alloc()
    let (local size_array : felt*) = alloc()
    local index = 0
    populate_view_philand(user,tokendata_array, coordinates_array, size_array,index, max)
    return (max, coordinates_array, max,size_array)
end

func populate_view_philand{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        user : Uint256, tokendata_array : felt *, coordinates_array : felt*, size_array : felt*, index : felt, max : felt):
    alloc_locals
    if index == max:
        return ()
    end

    let (local val0) = _user_philand_object.read(user=user, idx=index)
    let (token_array : felt*) = alloc()
    assert [token_array] = val0.contract_address
    assert [token_array + 1] = val0.token_id.low
    assert [token_array + 2] = val0.token_id.high
    tokendata_array[0] = token_array

    let (xyz_array : felt*) = alloc()
    assert [xyz_array] = val0.x_start
    assert [xyz_array + 1] = val0.y_start
    assert [xyz_array + 2] = val0.z_start
    coordinates_array[0] = xyz_array

    let (xyz_size_array : felt*) = alloc()
    assert [xyz_size_array] = val0.x_size
    assert [xyz_size_array + 1] = val0.y_size
    assert [xyz_size_array + 2] = val0.z_size
    size_array[0] = xyz_size_array


    populate_view_philand(user, tokendata_array + 3,coordinates_array + 3, size_array + 3,index + 1, max)
    return ()
end

@view
func view_links{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        user : Uint256
    ) -> (
    ):

  
    return ()
end

# Returns philand setting data (created,update,type).
@view
func view_setting{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(user :Uint256) -> (created_at : felt,updated_at : felt,land_type : felt, spawn_link : Spawnlink,text_records :felt):
    let (created_at) = _settings.read(user, SettingEnum.created_at)
    let (updated_at) = _settings.read(user, SettingEnum.updated_at)
    let (land_type) = _settings.read(user, SettingEnum.land_type)
    let (spawn_link) = _setting_link.read(user, SettingEnum.spawn_link)
    let (text_records)=_settings.read(user, SettingEnum.text_records)
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


