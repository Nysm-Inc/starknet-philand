import pytest
import asyncio
import numpy
from starkware.starknet.testing.starknet import Starknet
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.definitions.error_codes import StarknetErrorCode
from utils import str_to_felt, felt_to_str, Signer, uint, str_to_felt_array, to_split_uint
import time


signer = Signer(123456789987654321)
other = Signer(123456789987654321)
STARTING_PRICE = uint(500)

# ENS_NAME = "zak3939.eth"
# ENS_NAME_INT = 5354291560282261680205140228934436588969903936754548205611172710617586860032

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def bonus_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        "contracts/openzeppelin/account/Account.cairo",
        constructor_calldata=[signer.public_key]
    )
    treasury = await starknet.deploy(
        "contracts/openzeppelin/account/Account.cairo",
        constructor_calldata=[other.public_key]
    )

    xoroshiro128 = await starknet.deploy(
        "contracts/l2/utils/Xoroshiro128.cairo",
        constructor_calldata=[161803398]
    )

    primitiveMaterial = await starknet.deploy(
        "contracts/l2/PrimitiveMaterial.cairo",
        constructor_calldata=[account.contract_address
            # int.from_bytes("object".encode("ascii"), 'big'),
            # 0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599,
            # int.from_bytes("{id}".encode("ascii"), 'big')
        ]
    )
    # ERC20 type accepted as payment
    erc20 = await starknet.deploy(
        "contracts/l2/token/ERC20_Mintable.cairo",
        constructor_calldata=[
            str_to_felt("Mintable Token"),
            str_to_felt("MTKN"),
            18,
            *STARTING_PRICE,
            account.contract_address,
            account.contract_address
        ]
    )
    bonus = await starknet.deploy(
        "contracts/l2/DailyBonus.cairo",
        constructor_calldata=[
            xoroshiro128.contract_address,
            primitiveMaterial.contract_address,
            erc20.contract_address,
            treasury.contract_address
        ]
    )
    await signer.send_transaction(
        account=account,
        to=erc20.contract_address,
        selector_name="approve",
        calldata=[bonus.contract_address, *STARTING_PRICE]
    )

    return starknet, primitiveMaterial, bonus, account, treasury


@pytest.mark.asyncio
async def test_get_start_reward(bonus_factory):
    _, primitiveMaterial, bonus, account, _ = bonus_factory

    accounts = [account.contract_address, account.contract_address, account.contract_address,
                account.contract_address]
    token_ids = [(0, 0), (1, 0), (2, 0), (3, 0)]
    execution_info = await primitiveMaterial.balance_of_batch(accounts, token_ids).call()
    assert execution_info.result.res == [0, 0, 0, 0]

    await signer.send_transaction(account, bonus.contract_address, 'get_start_reward', [account.contract_address])
    execution_info = await primitiveMaterial.balance_of_batch(accounts, token_ids).call()

    print("balance")
    print(execution_info.result.res)

    assert sum(execution_info.result.res) == 10


@pytest.mark.asyncio
async def test_check_elapsed_time(bonus_factory):
    _, primitiveMaterial, bonus, account, _ = bonus_factory

    execution_info = await bonus.check_elapsed_time(account.contract_address).call()
    print(execution_info.result.elapsed_time)
    execution_info = await bonus.check_reward(account.contract_address).call()
    print("check:reward")
    print(execution_info.result.flg)
    assert execution_info.result.flg == 0

@pytest.mark.asyncio
async def test_get_reward(bonus_factory):
    _, primitiveMaterial, bonus, account, _ = bonus_factory
    
    accounts = [account.contract_address, account.contract_address, account.contract_address,
                account.contract_address]
    token_ids = [(0, 0), (1, 0), (2, 0), (3, 0)]
    execution_info = await primitiveMaterial.balance_of_batch(accounts, token_ids).call()
    # assert execution_info.result.res == [0,0,0,0]

    await signer.send_transaction(account, bonus.contract_address, 'get_reward_with_fee', [account.contract_address])
    execution_info = await primitiveMaterial.balance_of_batch(accounts, token_ids).call()

    print("balance")
    print(execution_info.result.res)

    assert sum(execution_info.result.res) == 11


@pytest.mark.asyncio
async def test_get_reward2(bonus_factory):
    _, primitiveMaterial, bonus, account, _ = bonus_factory

    accounts = [account.contract_address, account.contract_address, account.contract_address,
                account.contract_address]
    token_ids = [(0, 0), (5, 0), (6, 0), (7, 0)]
    execution_info = await primitiveMaterial.balance_of_batch(accounts, token_ids).call()
    # assert execution_info.result.res == [0, 0, 0, 0]

    await signer.send_transaction(account, bonus.contract_address, 'get_reward2', [])
    execution_info = await primitiveMaterial.balance_of_batch(accounts, token_ids).call()

    print("balance")
    print(execution_info.result.res)

    # assert sum(execution_info.result.res) == 1
