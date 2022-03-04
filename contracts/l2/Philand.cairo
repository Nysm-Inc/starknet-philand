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

#
#######################
struct AssetNamespace:
    member a : felt
end

# Contract Address on L1. An address is represented using 20 bytes. Those bytes are written in the `felt`.
struct AssetReference:
    member a : felt
end

# ERC1155 returns the same URI for all token types.
# TokenId will be represented by the substring '{id}' and so stored in a felt
# Client calling the function must replace the '{id}' substring with the actual token type ID
struct TokenId:
    member a : felt
end

struct TokenUri:
    member asset_namespace : AssetNamespace
    member asset_reference : AssetReference
    member token_id : TokenId
end

@contract_interface
namespace IObject:
    func _set_uri(uri_ : TokenUri):
    end
    
    func _mint(to : felt, token_id : felt, amount : felt):
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


##### Storage #####

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


struct Maplink:
    member x : felt
    member y : felt
    member contract_address : felt
    member owner : felt
end

@storage_var
func _link_num(owner: felt) -> (res : felt):
end

@storage_var
func _maplinks(owner: felt, link_index : felt) -> (res : Maplink):
end


struct SettingEnum:
    member created_at : felt
    member updated_at : felt
    member land_type : felt
    member text_records : felt
end


@storage_var
func _settings(owner: felt, setting_index : felt) -> (res : felt):
end


@storage_var
func parcel_meta(
        owner : felt,
        storage_index : felt
    ) -> (
        res : felt
    ):
end

@storage_var
func object_index(
    ) -> (
         res : felt
    ):
end

struct Tokendata:
    member contract_address : felt
    member token_id : Uint256
end

@storage_var
func object_info(
        object_id : felt
    ) -> (
        res : Tokendata
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
func _object_address() -> (res : felt):
end

@storage_var
func _l1_philand_address() -> (res : felt):
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
    object_index.write(0)
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
        owner : felt,
    ):
    # Accepts a 64 element list representing the objects.
    alloc_locals

    assert_not_zero(owner)

    # write philand parcel
    parcel.write(owner=owner, x=0, y=0, value=0)
    parcel.write(owner=owner, x=0, y=1, value=0)
    parcel.write(owner=owner, x=0, y=2, value=0)
    parcel.write(owner=owner, x=0, y=3, value=0)
    parcel.write(owner=owner, x=0, y=4, value=0)
    parcel.write(owner=owner, x=0, y=5, value=0)
    parcel.write(owner=owner, x=0, y=6, value=0)
    parcel.write(owner=owner, x=0, y=7, value=0)
    parcel.write(owner=owner, x=1, y=0, value=0)
    parcel.write(owner=owner, x=1, y=1, value=0)
    parcel.write(owner=owner, x=1, y=2, value=0)
    parcel.write(owner=owner, x=1, y=3, value=0)
    parcel.write(owner=owner, x=1, y=4, value=0)
    parcel.write(owner=owner, x=1, y=5, value=0)
    parcel.write(owner=owner, x=1, y=6, value=0)
    parcel.write(owner=owner, x=1, y=7, value=0)
    parcel.write(owner=owner, x=2, y=0, value=0)
    parcel.write(owner=owner, x=2, y=1, value=0)
    parcel.write(owner=owner, x=2, y=2, value=0)
    parcel.write(owner=owner, x=2, y=3, value=0)
    parcel.write(owner=owner, x=2, y=4, value=0)
    parcel.write(owner=owner, x=2, y=5, value=0)
    parcel.write(owner=owner, x=2, y=6, value=0)
    parcel.write(owner=owner, x=2, y=7, value=0)
    parcel.write(owner=owner, x=3, y=0, value=0)
    parcel.write(owner=owner, x=3, y=1, value=0)
    parcel.write(owner=owner, x=3, y=2, value=0)
    parcel.write(owner=owner, x=3, y=3, value=0)
    parcel.write(owner=owner, x=3, y=4, value=0)
    parcel.write(owner=owner, x=3, y=5, value=0)
    parcel.write(owner=owner, x=3, y=6, value=0)
    parcel.write(owner=owner, x=3, y=7, value=0)
    parcel.write(owner=owner, x=4, y=0, value=0)
    parcel.write(owner=owner, x=4, y=1, value=0)
    parcel.write(owner=owner, x=4, y=2, value=0)
    parcel.write(owner=owner, x=4, y=3, value=0)
    parcel.write(owner=owner, x=4, y=4, value=0)
    parcel.write(owner=owner, x=4, y=5, value=0)
    parcel.write(owner=owner, x=4, y=6, value=0)
    parcel.write(owner=owner, x=4, y=7, value=0)
    parcel.write(owner=owner, x=5, y=0, value=0)
    parcel.write(owner=owner, x=5, y=1, value=0)
    parcel.write(owner=owner, x=5, y=2, value=0)
    parcel.write(owner=owner, x=5, y=3, value=0)
    parcel.write(owner=owner, x=5, y=4, value=0)
    parcel.write(owner=owner, x=5, y=5, value=0)
    parcel.write(owner=owner, x=5, y=6, value=0)
    parcel.write(owner=owner, x=5, y=7, value=0)
    parcel.write(owner=owner, x=6, y=0, value=0)
    parcel.write(owner=owner, x=6, y=1, value=0)
    parcel.write(owner=owner, x=6, y=2, value=0)
    parcel.write(owner=owner, x=6, y=3, value=0)
    parcel.write(owner=owner, x=6, y=4, value=0)
    parcel.write(owner=owner, x=6, y=5, value=0)
    parcel.write(owner=owner, x=6, y=6, value=0)
    parcel.write(owner=owner, x=6, y=7, value=0)
    parcel.write(owner=owner, x=7, y=0, value=0)
    parcel.write(owner=owner, x=7, y=1, value=0)
    parcel.write(owner=owner, x=7, y=2, value=0)
    parcel.write(owner=owner, x=7, y=3, value=0)
    parcel.write(owner=owner, x=7, y=4, value=0)
    parcel.write(owner=owner, x=7, y=5, value=0)
    parcel.write(owner=owner, x=7, y=6, value=0)
    parcel.write(owner=owner, x=7, y=7, value=0)

    # create init setting
    let (block_timestamp) = get_block_timestamp()
    _settings.write(owner, SettingEnum.created_at,block_timestamp)
    _settings.write(owner, SettingEnum.updated_at,block_timestamp)
    _settings.write(owner, SettingEnum.land_type,0)
    _settings.write(owner, SettingEnum.text_records,0)

    let new_link = Maplink(
        x = 0,
        y = 0,
        contract_address = 0,
        owner = 0
    )

    _maplinks.write(owner, 0, new_link)

    return ()
end

# set new land type
@external
func write_setting{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner :felt,land_type : felt):
    _settings.write(owner, SettingEnum.land_type,land_type)
    return ()
end

# Create New lint to philand at specific parcel
@external
func write_newlink{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner : felt, x : felt, y : felt, contract_address : felt, target_owner : felt ):
    alloc_locals

    let (local num ) = view_link_num(owner)
    let new_index = num + 1
    let new_link = Maplink(
        x = x,
        y = y,
        contract_address = contract_address,
        owner = target_owner
    )

    _maplinks.write(owner, new_index, new_link)
    _link_num.write(owner, new_index)
    return ()
end

# @external
# func claim_starter_object{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(
#         owner : felt,
#         object_id : felt
#     ):
#     # check valid recipient
#     with_attr error_message("Object/invalid-recipient"):
#     #   assert_not_zero(account)
#       let (caller_address) = get_caller_address()
#       assert_not_zero(caller_address)
#     end

#     # todo already claimed
#     with_attr error_message("Object/invalid-nft"):
#     #   assert_not_zero(num)
#     end

#     # with_attr error_message("Object/invalid-token_id"):
#     #   let (nftOwner) = IObject.ownerOf(token_id)
#     # end

#     object_owner.write(owner=owner,object_id=1,value=1)
#     object_owner.write(owner=owner,object_id=2,value=1)
#     return ()
# end


@l1_handler
func claim_l1_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt,
        owner : felt,
        contract_address : felt,
        token_id : Uint256
    ):
    create_l1nft_object(contract_address,token_id)
    let (current_index) = object_index.read()
    object_owner.write(owner,current_index,1)
    return ()
end

@l1_handler
func claim_l2_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        from_address : felt,
        owner : felt,
        contract_address : felt,
        token_id : Uint256
    ):
    # todo setowner=>L2addresss
    let (current_index) = object_index.read()
    let idx = current_index + 1
    object_index.write(idx)
    object_owner.write(owner,current_index,1)
    let newTokendata= Tokendata(contract_address=contract_address,token_id=token_id)
    object_info.write(idx,newTokendata)
    return ()
end

# Philand contract object index
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


# Write object id to parcel
@external
func write_object_to_parcel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        x : felt,
        y : felt,
        owner : felt,
        object_id : felt
    ):
    
    parcel.write(owner, x, y,value=object_id)
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
        owner : felt,
        object_id_len : felt,
        object_id : felt*
    ):
    assert x_len = y_len
    assert x_len = object_id_len
    if x_len == 0:
        return ()
    end
    parcel.write(owner, [x], [y],value=[object_id])
    return batch_write_object_to_parcel(
        x_len = x_len - 1,
        x = x + 1,
        y_len = y_len - 1,
        y = y + 1,
        owner = owner,
        object_id_len = object_id_len - 1,
        object_id = object_id + 1)
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

# Returns parcel object data (contract_address, token_id).
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
        contract_address : felt,
        token_id : Uint256
    ):
    let (object_id) = parcel.read(owner, x, y)
    let (token) = object_info.read(object_id)
    return (token.contract_address, token.token_id)
end

# Returns philand owner setting link num
@view
func view_link_num{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner :felt) -> (num : felt):
    let (num) = _link_num.read(owner)
    return (num)
end

# Returns philand owner link 
@view
func view_link{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner :felt, link_index : felt) -> (link : Maplink):
    let (link) =_maplinks.read(owner, link_index)
    return (link)
end

# Returns philand setting data (created,update,type).
@view
func view_setting{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(owner :felt) -> (created_at : felt,updated_at : felt,land_type : felt):
    let (created_at) = _settings.read(owner, SettingEnum.created_at)
    let (updated_at) = _settings.read(owner, SettingEnum.updated_at)
    let (land_type) = _settings.read(owner, SettingEnum.land_type)
    return (created_at,updated_at,land_type)
end

# Returns parcel object data (contract_address, token_id).
@view
func view_object{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        object_id : felt
    ) -> (
        contract_address : felt,
        token_id : Uint256
    ):
    let (token) = object_info.read(object_id)
    return (token.contract_address, token.token_id)
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
    let (current_index) = object_index.read()
    let idx = current_index + 1
    object_index.write(idx)
    let newTokendata= Tokendata(contract_address=contract_address,token_id=token_id)
    object_info.write(idx,newTokendata)

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

    let newTokendata = Tokendata(contract_address=contract_address,token_id=token_id)

    let (local current_index) = object_index.read()
    let idx = current_index + 1
    object_index.write(idx)
    object_info.write(idx,newTokendata)

    return ()
end