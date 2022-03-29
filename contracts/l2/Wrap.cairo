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

from contracts.l2.utils.safemath import (
    uint256_checked_div_rem
) 

from contracts.l2.interfaces.ICraftedMaterial import ICraftedMaterial 
from contracts.l2.interfaces.IPrimitiveMaterial import IPrimitiveMaterial 
from contracts.l2.interfaces.IWrapPrimitiveMaterial import IWrapPrimitiveMaterial
from contracts.l2.interfaces.IWrapCraftedMaterial import IWrapCraftedMaterial

@storage_var
func _wrap_primitive_material_address() -> (res : felt):
end

@storage_var
func _wrap_crafted_material_address() -> (res : felt):
end

@storage_var
func _primitive_material_address() -> (res : felt):
end

@storage_var
func _crafted_material_address() -> (res : felt):
end

##### Constants #####
# Width of the simulation grid.

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    primitive_material_address : felt,
    crafted_material_address : felt,
    wrap_primitive_material_address : felt,
    wrap_crafted_material_address : felt
    ):

    _primitive_material_address.write(primitive_material_address)
    _crafted_material_address.write(crafted_material_address)
    _wrap_primitive_material_address.write(wrap_primitive_material_address)
    _wrap_crafted_material_address.write(wrap_crafted_material_address)
    
    return ()
end


##### Public functions #####

@external
func wrap_primitive_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals

    let (primitive_material_address) = _primitive_material_address.read()
    let (wrap_primitive_material_address) = _wrap_primitive_material_address.read()

    let (account_from_balance) = IPrimitiveMaterial.balance_of(primitive_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    IPrimitiveMaterial._burn(primitive_material_address,_from =owner, token_id = token_id, amount=amount)
    IWrapPrimitiveMaterial._mint(wrap_primitive_material_address,to=owner, token_id = token_id, amount=amount)

    return ()
end

@external
func batch_wrap_primitive_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    tokens_id_len : felt,
    tokens_id : Uint256*,
    amounts_len : felt, 
    amounts : felt*
    ):
    alloc_locals

    let (primitive_material_address) = _primitive_material_address.read()
    let (wrap_primitive_material_address) = _wrap_primitive_material_address.read()

    IPrimitiveMaterial._burn_batch(primitive_material_address,
        _from = owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
        
    IWrapPrimitiveMaterial._mint_batch(wrap_primitive_material_address,
        to=owner, 
        tokens_id_len =tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)

    return ()
end

@external
func unwrap_primitive_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals
    let (wrap_primitive_material_address) = _wrap_primitive_material_address.read()
    let (primitive_material_address) = _primitive_material_address.read()

    let (account_from_balance) = IWrapPrimitiveMaterial.balance_of(wrap_primitive_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    IWrapPrimitiveMaterial._burn(wrap_primitive_material_address,_from = owner, token_id = token_id, amount=amount)
    IPrimitiveMaterial._mint(primitive_material_address,to=owner, token_id = token_id, amount=amount)

    return ()
end

@external
func batch_unwrap_primitive_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    tokens_id_len : felt,
    tokens_id : Uint256*,
    amounts_len : felt, 
    amounts : felt*
    ):
    alloc_locals
    let (wrap_primitive_material_address) = _wrap_primitive_material_address.read()
    let (primitive_material_address) = _primitive_material_address.read()

    IWrapPrimitiveMaterial._burn_batch(wrap_primitive_material_address,_from = owner,
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    IPrimitiveMaterial._mint_batch(primitive_material_address,to=owner,
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    return ()
end

@external
func wrap_crafted_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals
    
    let (crafted_material_address) = _crafted_material_address.read()
    let (wrap_crafted_material_address) = _wrap_crafted_material_address.read()

    let (account_from_balance) = ICraftedMaterial.balance_of(crafted_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    ICraftedMaterial._burn(crafted_material_address,_from =owner, token_id = token_id, amount=amount)
    IWrapCraftedMaterial._mint(wrap_crafted_material_address,to=owner, token_id=token_id, amount=amount)

    return ()
end

@external
func batch_wrap_crafted_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    tokens_id_len : felt,
    tokens_id : Uint256*,
    amounts_len : felt, 
    amounts : felt*
    ):
    alloc_locals
    
    let (crafted_material_address) = _crafted_material_address.read()
    let (wrap_crafted_material_address) = _wrap_crafted_material_address.read()

    ICraftedMaterial._burn_batch(crafted_material_address,_from =owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    IWrapCraftedMaterial._mint_batch(wrap_crafted_material_address,to=owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    return ()
end

@external
func unwrap_crafted_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals
    let (wrap_crafted_material_address) = _wrap_crafted_material_address.read()
    let (crafted_material_address) = _crafted_material_address.read()

    let (account_from_balance) = IWrapCraftedMaterial.balance_of(wrap_crafted_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    IWrapCraftedMaterial._burn(wrap_crafted_material_address,_from =owner, token_id = token_id, amount=amount)
    ICraftedMaterial._mint(crafted_material_address,to=owner, token_id=token_id, amount=amount)

    return ()
end

@external
func batch_unwrap_crafted_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    tokens_id_len : felt,
    tokens_id : Uint256*,
    amounts_len : felt, 
    amounts : felt*
    ):
    alloc_locals
    let (wrap_crafted_material_address) = _wrap_crafted_material_address.read()
    let (crafted_material_address) = _crafted_material_address.read()

    IWrapCraftedMaterial._burn_batch(wrap_crafted_material_address,_from =owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    ICraftedMaterial._mint_batch(crafted_material_address,to=owner, 
    tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)

    return ()
end

@view
func wrap_primitive_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _wrap_primitive_material_address.read()
    return (res)
end

@view
func wrap_crafted_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _wrap_crafted_material_address.read()
    return (res)
end

@view
func primitive_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _primitive_material_address.read()
    return (res)
end

@view
func crafted_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _crafted_material_address.read()
    return (res)
end