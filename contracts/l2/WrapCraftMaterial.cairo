%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_nn_le, assert_not_equal, assert_not_zero, assert_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_lt, uint256_eq, uint256_check
)
from contracts.l2.utils.Ownable_base import (
    Ownable_initializer,
    Ownable_only_owner,
    Ownable_get_owner,
    Ownable_transfer_ownership
)

from contracts.l2.token.ERC721_Metadata_base import (
    ERC721_Metadata_initializer,
    ERC721_Metadata_tokenURI,
    ERC721_Metadata_setBaseTokenURI,
    ERC721_Metadata_setTokenURI,
    Metadata_tokenURI
)

from contracts.l2.token.ERC165_base import ERC165_supports_interface



#
# Storage
#

@storage_var
func balances(owner : felt, token_id : Uint256) -> (res : felt):
end

@storage_var
func operator_approvals(owner : felt, operator : felt) -> (res : felt):
end

@storage_var
func initialized() -> (res : felt):
end

# struct AssetNamespace:
#     member a : felt
# end

# Contract Address on L1. An address is represented using 20 bytes. Those bytes are written in the `felt`.
# struct AssetReference:
#     member a : felt
# end

# ERC1155 returns the same URI for all token types.
# TokenId will be represented by the substring '{id}' and so stored in a felt
# Client calling the function must replace the '{id}' substring with the actual token type ID
# struct TokenId:
#     member a : felt
# end

# struct TokenUri:
#     member asset_namespace : AssetNamespace
#     member asset_reference : AssetReference
#     member token_id : TokenId
# end

# @storage_var
# func _uri() -> (res: TokenUri):
# end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token_id : felt,
        token_uri_len : felt,
        token_uri : felt*):

   # Set uri
    setTokenURI(token_uri_len, token_uri, Uint256(token_id,0))

    return ()
end

# func _set_uri{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(uri_ : TokenUri):
#     _uri.write(uri_)
#     return()
# end

#
# Initializer
#

# @external
# func initialize_batch{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
#         tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt, amounts : felt*, uri_ : TokenUri):
#     let (_initialized) = initialized.read()
#     assert _initialized = 0
#     initialized.write(1)
#     let (sender) = get_caller_address()
#     _mint_batch(sender, tokens_id_len, tokens_id, amounts_len, amounts)
#     # Set uri
#     _set_uri(uri_)
#     return ()
# end

@external
func _mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        to : felt, token_id : Uint256, amount : felt) -> ():
    assert_not_zero(to)
    let (res) = balances.read(owner=to, token_id=token_id)
    balances.write(to, token_id, res + amount)
    _add_token_enumeration(token_id)
    return ()
end

@external
func _mint_batch{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        to : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt,
        amounts : felt*) -> ():
    assert_not_zero(to)
    assert tokens_id_len = amounts_len

    if tokens_id_len == 0:
        return ()
    end
    _mint(to, tokens_id[0], amounts[0])
    return _mint_batch(
        to=to,
        tokens_id_len=tokens_id_len - 1,
        tokens_id=tokens_id + 2,
        amounts_len=amounts_len - 1,
        amounts=amounts + 1)
end

#
# Getters
#

# Returns the same URI for all tokens type ID
# Client calling the function must replace the {id} substring with the actual token type ID
# @view
# func uri{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : TokenUri):
#     let (res) = _uri.read()
#     return (res)
# end

@view
func balance_of{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        owner : felt, token_id : Uint256) -> (res : felt):
    assert_not_zero(owner)
    let (res) = balances.read(owner=owner, token_id=token_id)
    return (res)
end

@view
func balance_of_batch{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        owners_len : felt, owners : felt*, tokens_id_len : felt, tokens_id : Uint256*) -> (
        res_len : felt, res : felt*):
    assert owners_len = tokens_id_len
    alloc_locals
    local max = owners_len
    let (local ret_array : felt*) = alloc()
    local ret_index = 0
    populate_balance_of_batch(owners, tokens_id, ret_array, ret_index, max)
    return (max, ret_array)
end

func populate_balance_of_batch{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        owners : felt*, tokens_id : Uint256*, rett : felt*, ret_index : felt, max : felt):
    alloc_locals
    if ret_index == max:
        return ()
    end
    let (local retval0 : felt) = balances.read(owner=owners[0], token_id=tokens_id[0])
    rett[0] = retval0
    populate_balance_of_batch(owners + 1, tokens_id + 2, rett + 1, ret_index + 1, max)
    return ()
end

#
# Approvals
#

@view
func is_approved_for_all{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        account : felt, operator : felt) -> (res : felt):
    let (res) = operator_approvals.read(owner=account, operator=operator)
    return (res=res)
end

@external
func set_approval_for_all{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        operator : felt, approved : felt):
    let (account) = get_caller_address()
    assert_not_equal(account, operator)
    # ensure approved is a boolean (0 or 1)
    assert approved * (1 - approved) = 0
    operator_approvals.write(account, operator, approved)
    return ()
end

#
# Transfer from
#

@external
func safe_transfer_from{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        _from : felt, to : felt, token_id : Uint256, amount : felt):
    _assert_is_owner_or_approved(_from)
    _transfer_from(_from, to, token_id, amount)
    return ()
end

@external
func safe_batch_transfer_from{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        _from : felt, to : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt,
        amounts : felt*):
    _assert_is_owner_or_approved(_from)
    _batch_transfer_from(_from, to, tokens_id_len, tokens_id, amounts_len, amounts)
    return ()
end

func _transfer_from{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        sender : felt, recipient : felt, token_id : Uint256, amount : felt):
    # check recipient != 0
    assert_not_zero(recipient)

    # validate sender has enough funds
    let (sender_balance) = balances.read(owner=sender, token_id=token_id)
    assert_nn_le(amount, sender_balance)

    # substract from sender
    balances.write(sender, token_id, sender_balance - amount)
    _remove_token_enumeration(token_id)
    # add to recipient
    let (res) = balances.read(owner=recipient, token_id=token_id)
    balances.write(recipient, token_id, res + amount)
    _add_token_enumeration(token_id)
    return ()
end

func _batch_transfer_from{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        _from : felt, to : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt,
        amounts : felt*):
    assert tokens_id_len = amounts_len
    assert_not_zero(to)

    if tokens_id_len == 0:
        return ()
    end
    _transfer_from(_from, to, [tokens_id], [amounts])
    return _batch_transfer_from(
        _from=_from,
        to=to,
        tokens_id_len=tokens_id_len - 1,
        tokens_id=tokens_id + 2,
        amounts_len=amounts_len - 1,
        amounts=amounts + 1)
end

# function to test ERC1155 requirement : require(from == _msgSender() || isApprovedForAll(from, _msgSender())
func _assert_is_owner_or_approved{
        pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(address : felt):
    let (caller) = get_caller_address()

    if caller == address:
        return ()
    end

    let (operator_is_approved) = is_approved_for_all(account=address, operator=caller)
    assert operator_is_approved = 1
    return ()
end

#
# Burn
#

@external
func _burn{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        _from : felt, token_id : Uint256, amount : felt):
    assert_not_zero(_from)

    let (from_balance) = balance_of(_from, token_id)
    assert_le(amount, from_balance)
    balances.write(_from, token_id, from_balance - amount)
    _remove_token_enumeration(token_id)
    return ()
end

@external
func _burn_batch{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        _from : felt, tokens_id_len : felt, tokens_id : Uint256*, amounts_len : felt, amounts : felt*):
    assert_not_zero(_from)

    assert tokens_id_len = amounts_len
    if tokens_id_len == 0:
        return ()
    end
    _burn(_from, [tokens_id], [amounts])
    return _burn_batch(
        _from=_from,
        tokens_id_len=tokens_id_len - 1,
        tokens_id=tokens_id + 2,
        amounts_len=amounts_len - 1,
        amounts=amounts + 1)
end


@external
func setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(token_uri_len : felt, token_uri : felt*, token_id : Uint256):
    # Ownable_only_owner()
    
    ERC721_Metadata_setTokenURI(token_uri_len, token_uri, token_id)
    return ()
end

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id : Uint256) -> (token_uri_len : felt, token_uri : felt*):
    let (token_uri_len, token_uri) = Metadata_tokenURI(token_id)
    return (token_uri_len=token_uri_len, token_uri=token_uri)
end

#
# Internals
#
@storage_var
func ERC1155_Enumerable_all_tokens_len() -> (res: Uint256):
end

@storage_var
func ERC1155_Enumerable_token_len(token_id: Uint256) -> (res: Uint256):
end

@view
func ERC1155_Enumerable_totalSupply{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*, 
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply) = ERC1155_Enumerable_all_tokens_len.read()
    return (totalSupply)
end

@view
func ERC1155_Enumerable_token_totalSupply{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*, 
        range_check_ptr
    }(token_id: Uint256) -> (totalSupply: Uint256):
    let (tokenSupply) = ERC1155_Enumerable_token_len.read(token_id=token_id)
    return (tokenSupply)
end

func _add_token_enumeration{
        pedersen_ptr: HashBuiltin*, 
        syscall_ptr: felt*, 
        range_check_ptr
    }(token_id: Uint256):
    alloc_locals
    let (supply: Uint256) = ERC1155_Enumerable_all_tokens_len.read()    
    let (local new_supply: Uint256, _) = uint256_add(supply, Uint256(1, 0))
    ERC1155_Enumerable_all_tokens_len.write(new_supply)

    let (supply_token: Uint256) = ERC1155_Enumerable_token_len.read(token_id)    
    let (local new_supply_token: Uint256, _) = uint256_add(supply, Uint256(1, 0))
    ERC1155_Enumerable_token_len.write(token_id=token_id,value=new_supply_token)
    return ()
end


func _remove_token_enumeration{
        pedersen_ptr: HashBuiltin*, 
        syscall_ptr: felt*, 
        range_check_ptr
    }(token_id: Uint256):
    alloc_locals
    let (local supply: Uint256) = ERC1155_Enumerable_all_tokens_len.read()
    let (local new_supply: Uint256) = uint256_sub(supply, Uint256(1, 0))
    ERC1155_Enumerable_all_tokens_len.write(new_supply)

    let (supply_token: Uint256) = ERC1155_Enumerable_token_len.read(token_id)    
    let (local new_supply_token: Uint256) = uint256_sub(supply, Uint256(1, 0))
    ERC1155_Enumerable_token_len.write(token_id=token_id,value=new_supply_token)
    return ()
end