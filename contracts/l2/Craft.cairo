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

from contracts.l2.interfaces.ICraftMaterial import ICraftMaterial 
from contracts.l2.interfaces.IDailyMaterial import IDailyMaterial

@storage_var
func get_stake_start_time_for_soilAndSeed_2_wood(
        owner : felt,
    ) -> (
        start_stake_time : felt
    ):
end

@storage_var
func get_stake_start_time_for_iron_2_steel(
        owner : felt,
    ) -> (
        start_stake_time : felt
    ):
end

@storage_var
func get_stake_start_time_for_oil_2_plastic(
        owner : felt,
    ) -> (
        start_stake_time : felt
    ):
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
    craft_material_address : felt
    ):
    
    _daily_material_address.write(daily_material_address)
    _craft_material_address.write(craft_material_address)

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
    let (daily_material_address) = _daily_material_address.read()
    let (craft_material_address) = _craft_material_address.read()
    let (account_from_balance) = IDailyMaterial.balance_of(daily_material_address,
        owner=sender_address, token_id=Uint256(0,0))
    assert_nn_le(4,account_from_balance)

    IDailyMaterial._burn(daily_material_address,_from = sender_address, token_id = Uint256(0,0), amount=4)
    ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(0,0), amount=1)
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
    let (craft_material_address) = _craft_material_address.read()

    let (account_from_balance) = ICraftMaterial.balance_of(craft_material_address,
        owner=sender_address, token_id=Uint256(0,0))
    assert_nn_le(4,account_from_balance)

    ICraftMaterial._burn(craft_material_address,_from =sender_address, token_id = Uint256(0,0), amount=4)
    ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(1,0), amount=1)
    return ()
end

@external
func stake_soilAndSeed_2_wood{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    # Check user has enough funds.
    let (local sender_address) = get_caller_address()
    let (daily_material_address) = _daily_material_address.read()
    let (craft_material_address) = _craft_material_address.read()
    let (update_time) = get_block_timestamp()

    let (sender_array : felt*) = alloc()
    assert [sender_array] = sender_address
    assert [sender_array + 1] = sender_address

    let (uint256_array : Uint256*) = alloc()
    assert [uint256_array] = Uint256(0,0)
    assert [uint256_array + 2] = Uint256(2,0)
    
    let (_,account_from_balances) = IDailyMaterial.balance_of_batch(daily_material_address,
        owners_len=2,owners=sender_array, tokens_id_len=2,tokens_id=uint256_array)
    assert_nn_le(1,account_from_balances[0])
    assert_nn_le(1,account_from_balances[1])

    let (felt_array : felt*) = alloc()
    assert [felt_array] = 1
    assert [felt_array + 1] = 1
    
    IDailyMaterial._burn_batch(daily_material_address,_from = sender_address, tokens_id_len=2, tokens_id=uint256_array, amounts_len=2, amounts=felt_array)
    get_stake_start_time_for_soilAndSeed_2_wood.write(owner=sender_address,value=update_time)
    
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
    let (craft_material_address) = _craft_material_address.read()
    let (local current_time) = get_block_timestamp()
    let (local last_stake_time) = get_stake_start_time_for_soilAndSeed_2_wood.read(sender_address)
    if last_stake_time == 0:
        return()
    end
    let elapsed_time = current_time - last_stake_time
    let (local flg) = is_nn(elapsed_time - 100)
    
    if flg ==1:
        ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(2,0), amount=1)
        get_stake_start_time_for_soilAndSeed_2_wood.write(owner=sender_address,value=0)
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
    let (daily_material_address) = _daily_material_address.read()
    let (account_from_daily_balance) = IDailyMaterial.balance_of(daily_material_address,
        owner=sender_address, token_id=Uint256(3,0))
    assert_nn_le(1,account_from_daily_balance)

    let (craft_material_address) = _craft_material_address.read()
    let (account_from_craft_balance) = ICraftMaterial.balance_of(craft_material_address,
        owner=sender_address, token_id=Uint256(2,0))
    assert_nn_le(1,account_from_craft_balance)

    IDailyMaterial._burn(daily_material_address,_from =sender_address, token_id = Uint256(3,0), amount=1)
    ICraftMaterial._burn(craft_material_address,_from =sender_address, token_id = Uint256(2,0), amount=1)
    ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(3,0), amount=1)
    return ()
end

@external
func stake_iron_2_steel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (update_time) = get_block_timestamp()
    let (daily_material_address) = _daily_material_address.read()

    let (account_from_balance) = IDailyMaterial.balance_of(daily_material_address,
        owner=sender_address, token_id=Uint256(3,0))
    assert_nn_le(1,account_from_balance)

    IDailyMaterial._burn(daily_material_address,_from =sender_address, token_id = Uint256(3,0), amount=1)
    get_stake_start_time_for_iron_2_steel.write(owner=sender_address,value=update_time)
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
    let (craft_material_address) = _craft_material_address.read()
    let (local current_time) = get_block_timestamp()
    let (local last_stake_time) = get_stake_start_time_for_iron_2_steel.read(sender_address)
    if last_stake_time == 0:
        return()
    end
    let elapsed_time = current_time - last_stake_time
    let (local flg) = is_nn(elapsed_time - 100)
    
    if flg ==1:
        ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(4,0), amount=1)
        get_stake_start_time_for_iron_2_steel.write(owner=sender_address,value=0)
        return()
    else:
        return ()
    end
end

@external
func stake_oil_2_plastic{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals
    let (local sender_address) = get_caller_address()
    # Check user has enough funds.
    let (update_time) = get_block_timestamp()
    let (daily_material_address) = _daily_material_address.read()
    let (craft_material_address) = _craft_material_address.read()
    let (account_from_balance) = IDailyMaterial.balance_of(daily_material_address,
        owner=sender_address, token_id=Uint256(1,0))
    assert_nn_le(1,account_from_balance)

    IDailyMaterial._burn(daily_material_address,_from =sender_address, token_id = Uint256(1,0), amount=1)
    get_stake_start_time_for_oil_2_plastic.write(owner=sender_address,value=update_time)
    
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
    let (craft_material_address) = _craft_material_address.read()
    let (local current_time) = get_block_timestamp()
    let (local last_stake_time) = get_stake_start_time_for_oil_2_plastic.read(sender_address)
    if last_stake_time == 0:
        return()
    end
    let elapsed_time = current_time - last_stake_time
    let (local flg) = is_nn(elapsed_time - 100)
    
    if flg ==1:
        ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(5,0), amount=1)
        get_stake_start_time_for_oil_2_plastic.write(owner=sender_address,value=0)
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
    let (craft_material_address) = _craft_material_address.read()

    let (sender_array : felt*) = alloc()
    assert [sender_array] = sender_address
    assert [sender_array + 1] = sender_address

    let (uint256_array : Uint256*) = alloc()
    assert [uint256_array] = Uint256(5,0)
    assert [uint256_array + 2] = Uint256(4,0)
    
    let (_,account_from_balances) = ICraftMaterial.balance_of_batch(craft_material_address,
        owners_len=2,owners=sender_array, tokens_id_len=2,tokens_id=uint256_array)
    assert_nn_le(2,account_from_balances[0])
    assert_nn_le(1,account_from_balances[1])

    let (felt_array : felt*) = alloc()
    assert [felt_array] = 2
    assert [felt_array + 1] = 1
    
    ICraftMaterial._burn_batch(craft_material_address,_from = sender_address, tokens_id_len=2, tokens_id=uint256_array, amounts_len=2, amounts=felt_array)
    ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(6,0), amount=1)
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
    let (craft_material_address) = _craft_material_address.read()

    let (account_from_balance) = ICraftMaterial.balance_of(craft_material_address,
        owner=sender_address, token_id=Uint256(6,0))
    assert_nn_le(4,account_from_balance)

    ICraftMaterial._burn(craft_material_address,_from =sender_address, token_id = Uint256(6,0), amount=4)
    ICraftMaterial._mint(craft_material_address,to=sender_address, token_id=Uint256(7,0), amount=1)
    return ()
end

@view
func check_elapsed_stake_time_soilAndSeed_2_wood{
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
    let (local last_stake_time)= get_stake_start_time_for_soilAndSeed_2_wood.read(sender_address)
    if last_stake_time == 0:
        return(0)
    end
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time -  last_stake_time
    return (elapsed_time)
end 

@view
func check_elapsed_stake_time_iron_2_steel{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    sender_address :felt )-> (
    elapsed_time : felt
    ):
    alloc_locals
    # let (local sender_address) = get_caller_address()
    let (local last_stake_time)= get_stake_start_time_for_iron_2_steel.read(sender_address)
    if last_stake_time == 0:
        return(0)
    end
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_stake_time
    return (elapsed_time)
end 

@view
func check_elapsed_stake_time_oil_2_plastic{
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
    let (local last_stake_time)= get_stake_start_time_for_oil_2_plastic.read(sender_address)
    if last_stake_time == 0:
        return(0)
    end
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_stake_time
    return (elapsed_time)
end 

@view
func daily_material_address{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }() -> (res : felt):
    let (res) = _daily_material_address.read()
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