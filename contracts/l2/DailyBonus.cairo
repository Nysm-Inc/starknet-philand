%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import (HashBuiltin,
    BitwiseBuiltin)
from starkware.cairo.common.math import (
    assert_le,
    assert_not_equal,
    split_felt,
    unsigned_div_rem
)
from starkware.cairo.common.hash_state import (hash_init,
    hash_update, HashState)
from starkware.starknet.common.syscalls import (call_contract,get_block_number,
    get_caller_address,get_block_timestamp,get_contract_address)

from starkware.cairo.common.math_cmp import (is_nn_le,is_nn,is_le, is_in_range)
from starkware.cairo.common.uint256 import (Uint256, uint256_add, uint256_sub, uint256_shl, uint256_lt, uint256_unsigned_div_rem)

from contracts.l2.token.IERC20 import IERC20
from contracts.l2.utils.safemath import (
    uint256_checked_add,
    uint256_checked_sub_le,
    uint256_checked_div_rem,
    uint256_checked_mul
) 
from starkware.cairo.common.bitwise import bitwise_and

from contracts.l2.interfaces.IPrimitiveMaterial import IPrimitiveMaterial 
from contracts.l2.interfaces.IXoroshiro import IXoroshiro 

from contracts.l2.lib.keccak import keccak256
from contracts.l2.lib.swap_endianness import swap_endianness_64

const TOP = 0xffffffffffffffff0000000000000000
const BOTTOM = 0xffffffffffffffff

@storage_var
func _last_rnd()  -> (res : felt):
end

@storage_var
func _fee()  -> (res : Uint256):
end

@storage_var
func _treasurey_address()  -> (res : felt):
end

@storage_var
func get_last_login_time(
        owner : felt,
    ) -> (
        last_login_time : felt
    ):
end

@storage_var
func _actual_result_gold(block_number : felt)  -> (res : felt):
end

@storage_var
func _gold_parcent(block_number : felt)  -> (res : Uint256):
end

@storage_var
func _actual_result_crystal(block_number : felt )  -> (res : felt):
end

@storage_var
func _crystal_parcent(block_number : felt)  -> (res : Uint256):
end

@storage_var
func _IXoroshiro_address() -> (res : felt):
end

@storage_var
func _primitive_material_address() -> (res : felt):
end

@storage_var
func _erc20Address()  -> (res : felt):
end

@storage_var
func _treasury_address()  -> (res : felt):
end


##### Event #####
@event
func meta_mint_event(
        owner : felt, last_login_time : felt):
end

##### Constants #####
# Width of the simulation grid.

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    IXoroshiro_address : felt,
    primitive_material_address : felt,
    erc20Address : felt,
    treasury_address : felt
    ):

    _IXoroshiro_address.write(IXoroshiro_address)
    _primitive_material_address.write(primitive_material_address)
    _erc20Address.write(erc20Address)
    _treasurey_address.write(treasury_address)

    let (currentBlock) = get_block_number()
    _gold_parcent.write(currentBlock,Uint256(50,0))
    _crystal_parcent.write(currentBlock,Uint256(25,0))
    set_fee(Uint256(1,0))
    return ()
end


##### Public functions #####

@external
func get_next_rnd{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (rnd : felt):
    alloc_locals
    let (IXoroshiro_address) = _IXoroshiro_address.read()
    let (rnd) = IXoroshiro.next(contract_address=IXoroshiro_address)
    _last_rnd.write(rnd)
    return (rnd)
end

func _start_mint{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    bitwise_ptr : BitwiseBuiltin*,
    range_check_ptr}(
    primitive_material_address: felt, owner : felt, len : felt):
    alloc_locals
    if len == 0:
        return ()
    end
    
    let (rnd)=get_next_rnd()
    let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(4,0))
    
    # soil
    if rem.low == 0:
        IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(0,0),1)
        return _start_mint(
        primitive_material_address=primitive_material_address,
        owner=owner,
        len=len - 1,
        )
    end

    # oil
    if rem.low == 1:
        IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(1,0),1)
        return _start_mint(
        primitive_material_address=primitive_material_address,
        owner=owner,
        len=len - 1,
        )
    end

    # seed
    if rem.low == 2:
        IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(2,0),1)
        return _start_mint(
        primitive_material_address=primitive_material_address,
        owner=owner,
        len=len - 1,
        )
    end

    #  iron
    if rem.low == 3:
        IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(3,0),1)
        return _start_mint(
        primitive_material_address=primitive_material_address,
        owner=owner,
        len=len - 1,
        )
    end
    return _start_mint(
        primitive_material_address=primitive_material_address,
        owner=owner,
        len=len - 1,
        )

end

@external
func get_start_reward{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    ):
    alloc_locals
    let (local last_login_time) = get_last_login_time.read(owner)
    let (local primitive_material_address) =  _primitive_material_address.read()
    meta_mint_event.emit(owner=owner,last_login_time=last_login_time)
    if last_login_time == 0:
        let (local update_time) = get_block_timestamp()
        get_last_login_time.write(owner,update_time)
        _start_mint(primitive_material_address=primitive_material_address,owner=owner,len=10)
        return ()
    else:
        return ()
    end
end

@external
func get_reward_with_fee{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr
    }(
    owner : felt,
    ):
    alloc_locals
    
    let (fee) = get_fee()
    let (erc20Address) = _erc20Address.read()
    let (treasurey_address) = _treasurey_address.read()

    let (check) = check_reward(owner)
    IERC20.transferFrom(
        erc20Address,
        owner,
        treasurey_address,
        fee,
    )
    let (local primitive_material_address) =  _primitive_material_address.read()
    if check == 1:
        let (update_time) = get_block_timestamp()
        get_last_login_time.write(owner,update_time)

        let (rnd)=get_next_rnd()
        let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(100,0))
        let (local currentBlock) = get_block_number()
        let (flg_soil) = is_in_range(rem.low, 0,30)
        # soil
        if flg_soil == 1:
            IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(0,0),1)
            return ()
        end
        
        let (cb) = felt_to_uint256(currentBlock)
        let (oil_random) = random(cb,Uint256(30,0),Uint256(60,0))
        # oil
        let (flg_oil) = is_in_range(rem.low, 30,oil_random.low)
        if flg_oil == 1:
            IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(1,0),1)
            return ()
        end

        let (seed_random) = random(cb,oil_random,Uint256(90,0))
        let (flg_seed) = is_in_range(rem.low, oil_random.low,seed_random.low)
        # seed
        if flg_seed == 1:
            IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(2,0),1)
            return ()
        end

        let (flg_iron) = is_in_range(rem.low, seed_random.low,100)
        #  iron
        if flg_iron == 1:
            IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(3,0),1)
            return ()
        end
        return ()
    else:
        IPrimitiveMaterial._mint(primitive_material_address,owner,Uint256(0,0),1)
        return ()
    end
end

@external
func get_reward2{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    alloc_locals

    let (primitive_material_address) =  _primitive_material_address.read()
    let (local currentBlock) = get_block_number()
    
    let (count_gold) = _actual_result_gold.read(currentBlock)
    let (count_crystal) = _actual_result_crystal.read(currentBlock)

    let (user) = get_caller_address()
    let (fee) = get_fee()
    let (erc20Address) = _erc20Address.read()
    let (treasurey_address) = _treasurey_address.read()

    let (check) = check_reward(user)

    # Transfer ERC20 payment from buyer to seller
    IERC20.transferFrom(
        erc20Address,
        user,
        treasurey_address,
        fee,
    )

    if count_crystal == 0:
        let last_block_number = currentBlock - 1
        let (last_crystal_parcent) = _crystal_parcent.read(last_block_number)
        let (new_parcent : Uint256) = _recalc_crystal_parcent(last_block_number,last_crystal_parcent)      
        _crystal_parcent.write(currentBlock,new_parcent)

        IPrimitiveMaterial._mint(primitive_material_address,to=user,token_id=Uint256(6,0),amount=1)
        let new_count = count_crystal + 1
        _actual_result_crystal.write(currentBlock,new_count)
        return ()
    end

    if count_gold == 0:
        let last_block_number = currentBlock - 1
        let (last_gold_parcent) = _gold_parcent.read(last_block_number)
        let (new_parcent : Uint256) = _recalc_gold_parcent(last_block_number,last_gold_parcent)      
        _gold_parcent.write(currentBlock,new_parcent)

        IPrimitiveMaterial._mint(primitive_material_address,to=user,token_id=Uint256(5,0),amount=1)
        let new_count = count_gold + 1
        _actual_result_gold.write(currentBlock,new_count)
        return ()
    end

    let (rnd)= get_next_rnd()
    let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(100,0))
    let (gold_parcent) = _gold_parcent.read(currentBlock)
    let (crystal_parcent) = _crystal_parcent.read(currentBlock)
    let (local check) = is_nn_le(rem.low, gold_parcent.low)
    

    let (flg_crystal) = is_in_range(rem.low, 0,crystal_parcent.low)
    if flg_crystal == 1:
        IPrimitiveMaterial._mint(primitive_material_address,to=user,token_id=Uint256(6,0),amount=1)
        let new_count = count_crystal + 1
        _actual_result_crystal.write(currentBlock,new_count)
        return ()
    end

    let (flg_gold) = is_in_range(rem.low, gold_parcent.low, 100)
    if flg_gold == 1:
        IPrimitiveMaterial._mint(primitive_material_address,to=user,token_id=Uint256(5,0),amount=1)
        let new_count = count_gold + 1
        _actual_result_gold.write(currentBlock,new_count)
        return ()
    end

    IPrimitiveMaterial._mint(primitive_material_address,to=user,token_id=Uint256(0,0),amount=1)
    return ()
    
end

@view
func get_login_time{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    )-> (
    last_login_time : felt
    ):
    alloc_locals
    let (last_login_time)= get_last_login_time.read(owner)

    return (last_login_time)
end 

@view
func check_elapsed_time{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    )-> (
    elapsed_time : felt
    ):
    alloc_locals
    let (local last_login_time)= get_last_login_time.read(owner)
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_login_time
    return (elapsed_time)
end 

@view
func check_reward{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    owner : felt
    )-> (
    flg : felt
    ):
    alloc_locals
    let (local last_login_time) = get_last_login_time.read(owner)
    let (local current_time) = get_block_timestamp()
    let elapsed_time = current_time - last_login_time
    
    let (local flg) = is_nn(elapsed_time - 100)
    
    return (flg)
end 

@view
func get_latest_rnd{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (rnd : felt):
    alloc_locals
    let (rnd)=_last_rnd.read()
    return (rnd)
end

@view
func get_latest_100div_rnd{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (c : Uint256, rem : Uint256):
    alloc_locals
    let (rnd)=_last_rnd.read()
    let (c: Uint256, rem: Uint256) = uint256_checked_div_rem(Uint256(rnd,0),Uint256(100,0))
    return (c,rem)
end


@external
func set_fee{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(value : Uint256):
    alloc_locals

    _fee.write(value=value)
    return ()
end
@view
func get_fee{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }() -> (
        res : Uint256
    ):
    alloc_locals

    let (res) = _fee.read()
    return (res)
end

@view
func history_gold_parcent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(
    blockNumber : felt
    ) -> (
        gold_parcent : Uint256
    ):
    alloc_locals
   
    let (gold_parcent) = _gold_parcent.read(blockNumber)
    return (gold_parcent)
end

@view
func get_gold_parcent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }() -> (
        gold_parcent : Uint256
    ):
    alloc_locals
    let (local currentBlock) = get_block_number()
   
    let (gold_parcent) = _gold_parcent.read(currentBlock)
    return (gold_parcent)
end

@external
func _recalc_gold_parcent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    last_block_number : felt,
    last_gold_parcent : Uint256
    )-> (
    res : Uint256
    ):
    alloc_locals
    
    let (count_gold) = _actual_result_gold.read(last_block_number)
    let (a) = is_le(count_gold, 8)
    if a == 1:
        let (add_p: Uint256) = uint256_checked_sub_le(Uint256(8,0),Uint256(count_gold,0))
        let (new_parcent: Uint256) = uint256_checked_add(last_gold_parcent,add_p)
        let (check) = is_le(new_parcent.low,100)
        if check ==1:
            return (new_parcent)
        else:
            let max = Uint256(100,0)
            return (max)
        end
    end

    let (b) = is_le(count_gold, 12)
    if b ==1:
        return (last_gold_parcent)
    end

    let (check) = is_le(last_gold_parcent.low,12)
    if check ==1:
        return (last_gold_parcent)
    end

    let (sub_p: Uint256) = uint256_checked_sub_le(Uint256(count_gold,0),Uint256(12,0))
    let (check) = is_le(last_gold_parcent.low,sub_p.low)
    if check ==1:
        return (last_gold_parcent)
    else:
        let (new_parcent: Uint256)= uint256_checked_sub_le(last_gold_parcent,sub_p)
        return (new_parcent)
    end
end 


@view
func history_crystal_parcent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(
    blockNumber : felt
    ) -> (
        crystal_parcent : Uint256
    ):
    alloc_locals
   
    let (crystal_parcent) = _crystal_parcent.read(blockNumber)
    return (crystal_parcent)
end

@view
func get_crystal_parcent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }() -> (
        crystal_parcent : Uint256
    ):
    alloc_locals
    let (local currentBlock) = get_block_number()
   
    let (crystal_parcent) = _crystal_parcent.read(currentBlock)
    return (crystal_parcent)
end

@external
func _recalc_crystal_parcent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
    last_block_number : felt,
    last_crystal_parcent : Uint256
    )-> (
    res : Uint256
    ):
    alloc_locals
    
    let (count_crystal) = _actual_result_crystal.read(last_block_number)
    let (a) = is_le(count_crystal, 3)
    if a == 1:
        let (add_p: Uint256) = uint256_checked_sub_le(Uint256(3,0),Uint256(count_crystal,0))
        let (new_parcent: Uint256) = uint256_checked_add(last_crystal_parcent,add_p)
        let (check) = is_le(new_parcent.low,25)
        if check ==1:
            return (new_parcent)
        else:
            let max = Uint256(25,0)
            return (max)
        end
    end

    let (b) = is_le(count_crystal, 7)
    if b ==1:
        return (last_crystal_parcent)
    end

    let (check) = is_le(last_crystal_parcent.low,7)
    if check ==1:
        return (last_crystal_parcent)
    end

    let (sub_p: Uint256) = uint256_checked_sub_le(Uint256(count_crystal,0),Uint256(7,0))
    let (check) = is_le(last_crystal_parcent.low,sub_p.low)
    if check ==1:
        return (last_crystal_parcent)
    else:
        let (new_parcent: Uint256)= uint256_checked_sub_le(last_crystal_parcent,sub_p)
        return (new_parcent)
    end
end 

func random_seed_shift_min_max{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        seed : Uint256, shift : felt, min : felt, max : felt) -> (low : felt):
    let (shifted_seed) = uint256_shl(seed, Uint256(low=shift, high=0))
    let min_t = Uint256(low=min, high=0)
    let max_t = Uint256(low=max, high=0)
    let (rnd) = random(shifted_seed, min_t, max_t)
    return (rnd.low)
end

func hash_uint256{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(input : Uint256) -> (
        out : Uint256):
    alloc_locals

    # TODO: test

    # the input array for keccak256 has to be data split into 64 bit words
    # so here we build the those parts from two 128 bit words that make up
    # the Uint256 input; it's just some bit shifting using the stdlib

    let (t0) = bitwise_and(input.high, TOP)
    let (w0, _) = unsigned_div_rem(t0, BOTTOM)
    let (w1) = bitwise_and(input.high, BOTTOM)

    let (t2) = bitwise_and(input.low, TOP)
    let (w2, _) = unsigned_div_rem(t2, BOTTOM)
    let (w3) = bitwise_and(input.low, BOTTOM)

    let hash_data : felt* = alloc()
    assert hash_data[0] = w0
    assert hash_data[1] = w1
    assert hash_data[2] = w2
    assert hash_data[3] = w3

    let (keccak_ptr : felt*) = alloc()
    # four 64-bit words == 256 bits == 32 bytes
    let (hash) = keccak256{keccak_ptr=keccak_ptr}(hash_data, 32)

    # the output of keccak256 is an array of four 64 bit words in
    # little endian; to convert this to the return type fo Uint256
    # we first need to swap the endianness of each word and then
    # build the low 128 bit and high 128 bit parts of Uint256

    let (p0) = swap_endianness_64(hash[0], 8)
    let (p1) = swap_endianness_64(hash[1], 8)
    let (p2) = swap_endianness_64(hash[2], 8)
    let (p3) = swap_endianness_64(hash[3], 8)

    # (p0 * (1 << 64)) + p1
    let high = (p0 * 0x10000000000000000) + p1
    # (p2 * (1 << 64)) + p3
    let low = (p2 * 0x10000000000000000) + p3

    let rnd : Uint256 = Uint256(low=low, high=high)
    return (rnd)
end

@view
func random{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        input : Uint256, min : Uint256, max : Uint256) -> (out : Uint256):
    alloc_locals

    let (out) = hash_uint256(input)
    let (m) = uint256_sub(max, min)
    let (_, r) = uint256_unsigned_div_rem(out, m)
    let (out, _) = uint256_add(r, min)

    return (out)
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

func felt_to_uint256{range_check_ptr}(x) -> (x_ : Uint256):
    let split = split_felt(x)
    return (Uint256(low=split.low, high=split.high))
end