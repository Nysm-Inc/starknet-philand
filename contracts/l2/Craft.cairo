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

from contracts.l2.interfaces.ICraftedMaterial import ICraftedMaterial 
from contracts.l2.interfaces.IPrimitiveMaterial import IPrimitiveMaterial

@storage_var
func get_forge_start_time_for_soilAndSeed_2_wood(
        owner : felt,
    ) -> (
        start_forge_time : felt
    ):
end

@storage_var
func get_forge_start_time_for_iron_2_steel(
        owner : felt,
    ) -> (
        start_forge_time : felt
    ):
end

@storage_var
func get_forge_start_time_for_oil_2_plastic(
        owner : felt,
    ) -> (
        start_forge_time : felt
    ):
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
    crafted_material_address : felt
    ):
    
    _primitive_material_address.write(primitive_material_address)
    _crafted_material_address.write(crafted_material_address)

    return ()
end


##### Public functions #####
# 
@external
func craft_soil_2_brick{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    # Check user has enough funds.
    let (local sender_address) = get_caller_address()
    let (primitive_material_address) = _primitive_material_address.read()
    let (crafted_material_address) = _crafted_material_address.read()
    let (account_from_balance) = IPrimitiveMaterial.balance_of(primitive_material_address,
        owner=sender_address, token_id=Uint256(0,0))
    assert_nn_le(4,account_from_balance)

    IPrimitiveMaterial._burn(primitive_material_address,_from = sender_address, token_id = Uint256(0,0), amount=4)
    ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(0,0), amount=1)
    return ()
end

@external
func craft_brick_2_brickHouse{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (crafted_material_address) = _crafted_material_address.read()

    let (account_from_balance) = ICraftedMaterial.balance_of(crafted_material_address,
        owner=sender_address, token_id=Uint256(0,0))
    assert_nn_le(4,account_from_balance)

    ICraftedMaterial._burn(crafted_material_address,_from =sender_address, token_id = Uint256(0,0), amount=4)
    ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(1,0), amount=1)
    return ()
end

@external
func forge_soilAndSeed_2_wood{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    # Check user has enough funds.
    let (local sender_address) = get_caller_address()
    let (primitive_material_address) = _primitive_material_address.read()
    let (crafted_material_address) = _crafted_material_address.read()
    let (update_time) = get_block_timestamp()

    let (sender_array : felt*) = alloc()
    assert [sender_array] = sender_address
    assert [sender_array + 1] = sender_address

    let (uint256_array : Uint256*) = alloc()
    assert [uint256_array] = Uint256(0,0)
    assert [uint256_array + 2] = Uint256(2,0)
    
    let (_,account_from_balances) = IPrimitiveMaterial.balance_of_batch(primitive_material_address,
        owners_len=2,owners=sender_array, tokens_id_len=2,tokens_id=uint256_array)
    assert_nn_le(1,account_from_balances[0])
    assert_nn_le(1,account_from_balances[1])

    let (felt_array : felt*) = alloc()
    assert [felt_array] = 1
    assert [felt_array + 1] = 1
    
    IPrimitiveMaterial._burn_batch(primitive_material_address,_from = sender_address, tokens_id_len=2, tokens_id=uint256_array, amounts_len=2, amounts=felt_array)
    get_forge_start_time_for_soilAndSeed_2_wood.write(owner=sender_address,value=update_time)
    
    return ()
end

@external
func craft_soilAndSeed_2_wood{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (crafted_material_address) = _crafted_material_address.read()
    let (local current_time) = get_block_timestamp()
    let (local last_forge_time) = get_forge_start_time_for_soilAndSeed_2_wood.read(sender_address)
    if last_forge_time == 0:
        return()
    end
    let elapsed_time = current_time - last_forge_time
    let (local flg) = is_nn(elapsed_time - 100)
    
    if flg ==1:
        ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(2,0), amount=1)
        get_forge_start_time_for_soilAndSeed_2_wood.write(owner=sender_address,value=0)
        return()
    else:
        return ()
    end
end

@external
func craft_ironAndWood_2_ironSword{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (primitive_material_address) = _primitive_material_address.read()
    let (account_from_primitive_balance) = IPrimitiveMaterial.balance_of(primitive_material_address,
        owner=sender_address, token_id=Uint256(3,0))
    assert_nn_le(1,account_from_primitive_balance)

    let (crafted_material_address) = _crafted_material_address.read()
    let (account_from_crafted_balance) = ICraftedMaterial.balance_of(crafted_material_address,
        owner=sender_address, token_id=Uint256(2,0))
    assert_nn_le(1,account_from_crafted_balance)

    IPrimitiveMaterial._burn(primitive_material_address,_from =sender_address, token_id = Uint256(3,0), amount=1)
    ICraftedMaterial._burn(crafted_material_address,_from =sender_address, token_id = Uint256(2,0), amount=1)
    ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(3,0), amount=1)
    return ()
end

@external
func forge_iron_2_steel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (update_time) = get_block_timestamp()
    let (primitive_material_address) = _primitive_material_address.read()

    let (account_from_balance) = IPrimitiveMaterial.balance_of(primitive_material_address,
        owner=sender_address, token_id=Uint256(3,0))
    assert_nn_le(1,account_from_balance)

    IPrimitiveMaterial._burn(primitive_material_address,_from =sender_address, token_id = Uint256(3,0), amount=1)
    get_forge_start_time_for_iron_2_steel.write(owner=sender_address,value=update_time)
    return ()
end

@external
func craft_iron_2_steel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (crafted_material_address) = _crafted_material_address.read()
    let (local current_time) = get_block_timestamp()
    let (local last_forge_time) = get_forge_start_time_for_iron_2_steel.read(sender_address)
    if last_forge_time == 0:
        return()
    end
    let elapsed_time = current_time - last_forge_time
    let (local flg) = is_nn(elapsed_time - 100)
    
    if flg ==1:
        ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(4,0), amount=1)
        get_forge_start_time_for_iron_2_steel.write(owner=sender_address,value=0)
        return()
    else:
        return ()
    end
end

@external
func forge_oil_2_plastic{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (update_time) = get_block_timestamp()
    let (primitive_material_address) = _primitive_material_address.read()
    let (crafted_material_address) = _crafted_material_address.read()
    let (account_from_balance) = IPrimitiveMaterial.balance_of(primitive_material_address,
        owner=sender_address, token_id=Uint256(1,0))
    assert_nn_le(1,account_from_balance)

    IPrimitiveMaterial._burn(primitive_material_address,_from =sender_address, token_id = Uint256(1,0), amount=1)
    get_forge_start_time_for_oil_2_plastic.write(owner=sender_address,value=update_time)
    
    return ()
end

@external
func craft_oil_2_plastic{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (crafted_material_address) = _crafted_material_address.read()
    let (local current_time) = get_block_timestamp()
    let (local last_forge_time) = get_forge_start_time_for_oil_2_plastic.read(sender_address)
    if last_forge_time == 0:
        return()
    end
    let elapsed_time = current_time - last_forge_time
    let (local flg) = is_nn(elapsed_time - 100)
    
    if flg ==1:
        ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(5,0), amount=1)
        get_forge_start_time_for_oil_2_plastic.write(owner=sender_address,value=0)
        return()
    else:
        return ()
    end
end

@external
func craft_plasticAndSteel_2_computer{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (crafted_material_address) = _crafted_material_address.read()

    let (sender_array : felt*) = alloc()
    assert [sender_array] = sender_address
    assert [sender_array + 1] = sender_address

    let (uint256_array : Uint256*) = alloc()
    assert [uint256_array] = Uint256(5,0)
    assert [uint256_array + 2] = Uint256(4,0)
    
    let (_,account_from_balances) = ICraftedMaterial.balance_of_batch(crafted_material_address,
        owners_len=2,owners=sender_array, tokens_id_len=2,tokens_id=uint256_array)
    assert_nn_le(2,account_from_balances[0])
    assert_nn_le(1,account_from_balances[1])

    let (felt_array : felt*) = alloc()
    assert [felt_array] = 2
    assert [felt_array + 1] = 1
    
    ICraftedMaterial._burn_batch(crafted_material_address,_from = sender_address, tokens_id_len=2, tokens_id=uint256_array, amounts_len=2, amounts=felt_array)
    ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(6,0), amount=1)
    return ()
end

@external
func craft_computer_2_electronicsStore{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (crafted_material_address) = _crafted_material_address.read()

    let (account_from_balance) = ICraftedMaterial.balance_of(crafted_material_address,
        owner=sender_address, token_id=Uint256(6,0))
    assert_nn_le(4,account_from_balance)

    ICraftedMaterial._burn(crafted_material_address,_from =sender_address, token_id = Uint256(6,0), amount=4)
    ICraftedMaterial._mint(crafted_material_address,to=sender_address, token_id=Uint256(7,0), amount=1)
    return ()
end

@view
func check_elapsed_forge_time_soilAndSeed_2_wood{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    sender_address :felt
    )-> (
    elapsed_time : felt
    ):
    alloc_locals
    # let (local sender_address) = get_caller_address()
    let (local last_forge_time)= get_forge_start_time_for_soilAndSeed_2_wood.read(sender_address)
    if last_forge_time == 0:
        return(0)
    end
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time -  last_forge_time
    return (elapsed_time)
end 

@view
func check_elapsed_forge_time_iron_2_steel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    sender_address :felt )-> (
    elapsed_time : felt
    ):
    alloc_locals
    # let (local sender_address) = get_caller_address()
    let (local last_forge_time)= get_forge_start_time_for_iron_2_steel.read(sender_address)
    if last_forge_time == 0:
        return(0)
    end
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_forge_time
    return (elapsed_time)
end 

@view
func check_elapsed_forge_time_oil_2_plastic{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    sender_address :felt
    )-> (
    elapsed_time : felt
    ):
    alloc_locals
    # let (local sender_address) = get_caller_address()
    let (local last_forge_time)= get_forge_start_time_for_oil_2_plastic.read(sender_address)
    if last_forge_time == 0:
        return(0)
    end
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_forge_time
    return (elapsed_time)
end 

@view
func primitive_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _primitive_material_address.read()
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