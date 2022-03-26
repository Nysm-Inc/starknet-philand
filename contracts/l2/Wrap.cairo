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

from contracts.l2.interfaces.ICraftMaterial import ICraftMaterial 
from contracts.l2.interfaces.IDailyMaterial import IDailyMaterial 
from contracts.l2.interfaces.IWrapMaterial import IWrapMaterial
from contracts.l2.interfaces.IWrapCraftMaterial import IWrapCraftMaterial

@storage_var
func _wrap_material_address() -> (res : felt):
end

@storage_var
func _wrap_craft_material_address() -> (res : felt):
end

@storage_var
func _daily_material_address() -> (res : felt):
end

@storage_var
func _craft_material_address() -> (res : felt):
end

##### Constants #####
# Width of the simulation grid.

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    daily_material_address : felt,
    craft_material_address : felt,
    wrap_material_address : felt,
    wrap_craft_material_address : felt
    ):

    _daily_material_address.write(daily_material_address)
    _craft_material_address.write(craft_material_address)
    _wrap_material_address.write(wrap_material_address)
    _wrap_craft_material_address.write(wrap_craft_material_address)
    
    return ()
end


##### Public functions #####

@external
func wrap_daily_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals

    let (daily_material_address) = _daily_material_address.read()
    let (wrap_material_address) = _wrap_material_address.read()

    let (account_from_balance) = IDailyMaterial.balance_of(daily_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    IDailyMaterial._burn(daily_material_address,_from =owner, token_id = token_id, amount=amount)
    IWrapMaterial._mint(wrap_material_address,to=owner, token_id = token_id, amount=amount)

    return ()
end

@external
func batch_wrap_daily_material{
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

    let (daily_material_address) = _daily_material_address.read()
    let (wrap_material_address) = _wrap_material_address.read()

    IDailyMaterial._burn_batch(daily_material_address,_from = owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
        
    IWrapMaterial._mint_batch(wrap_material_address,to=owner, 
        tokens_id_len =tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)

    return ()
end

@external
func unwrap_daily_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals
    let (wrap_material_address) = _wrap_material_address.read()
    let (daily_material_address) = _daily_material_address.read()

    let (account_from_balance) = IWrapMaterial.balance_of(wrap_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    IWrapMaterial._burn(wrap_material_address,_from = owner, token_id = token_id, amount=amount)
    IDailyMaterial._mint(daily_material_address,to=owner, token_id = token_id, amount=amount)

    return ()
end

@external
func batch_unwrap_daily_material{
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
    let (wrap_material_address) = _wrap_material_address.read()
    let (daily_material_address) = _daily_material_address.read()

    IWrapMaterial._burn_batch(wrap_material_address,_from = owner,
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    IDailyMaterial._mint_batch(daily_material_address,to=owner,
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    return ()
end

@external
func wrap_craft_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals
    
    let (craft_material_address) = _craft_material_address.read()
    let (wrap_craft_material_address) = _wrap_craft_material_address.read()

    let (account_from_balance) = ICraftMaterial.balance_of(craft_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    ICraftMaterial._burn(craft_material_address,_from =owner, token_id = token_id, amount=amount)
    IWrapCraftMaterial._mint(wrap_craft_material_address,to=owner, token_id=token_id, amount=amount)

    return ()
end

@external
func batch_wrap_craft_material{
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
    
    let (craft_material_address) = _craft_material_address.read()
    let (wrap_craft_material_address) = _wrap_craft_material_address.read()

    ICraftMaterial._burn_batch(craft_material_address,_from =owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    IWrapCraftMaterial._mint_batch(wrap_craft_material_address,to=owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    return ()
end

@external
func unwrap_craft_material{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    token_id : Uint256,
    amount : felt
    ):
    alloc_locals
    let (wrap_craft_material_address) = _wrap_craft_material_address.read()
    let (craft_material_address) = _craft_material_address.read()

    let (account_from_balance) = IWrapCraftMaterial.balance_of(wrap_craft_material_address,
        owner=owner, token_id=token_id)
    assert_nn_le(amount,account_from_balance)

    IWrapCraftMaterial._burn(wrap_craft_material_address,_from =owner, token_id = token_id, amount=amount)
    ICraftMaterial._mint(craft_material_address,to=owner, token_id=token_id, amount=amount)

    return ()
end

@external
func batch_unwrap_craft_material{
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
    let (wrap_craft_material_address) = _wrap_craft_material_address.read()
    let (craft_material_address) = _craft_material_address.read()

    IWrapCraftMaterial._burn_batch(wrap_craft_material_address,_from =owner, 
        tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)
    ICraftMaterial._mint_batch(craft_material_address,to=owner, 
    tokens_id_len=tokens_id_len,
        tokens_id=tokens_id,
        amounts_len=amounts_len,
        amounts=amounts)

    return ()
end

@view
func wrap_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _wrap_material_address.read()
    return (res)
end

@view
func wrap_craft_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) =  _wrap_craft_material_address.read()
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

@view
func craft_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _craft_material_address.read()
    return (res)
end