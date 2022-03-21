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

ENS_NAME = "zak3939.eth"
ENS_NAME_INT = 5354291560282261680205140228934436588969903936754548205611172710617586860032

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def bonus_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        "contracts/l2/utils/Account.cairo",
        constructor_calldata=[signer.public_key]
    )
    operator = await starknet.deploy(
        "contracts/l2/utils/Account.cairo",
        constructor_calldata=[other.public_key]
    )

    xoroshiro128 = await starknet.deploy(
        "contracts/l2/utils/Xoroshiro128.cairo",
        constructor_calldata=[161803398]
    )

    dairyMaterial = await starknet.deploy(
        "contracts/l2/material/token/DailyMaterial.cairo",
        constructor_calldata=[
            1,
            4,
            184555836509371486644019136839411173249852705485729074225653387927518275942,
            210616560794178717850935920065495060911188822037429046327979330294206130042,
            187985923959723853589968256655376306670773667376910287781628159691950468714,
            7565166,
            # int.from_bytes("object".encode("ascii"), 'big'),
            # 0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599,
            # int.from_bytes("{id}".encode("ascii"), 'big')
        ]
    )

    bonus = await starknet.deploy(
        "contracts/l2/material/DailyBonus.cairo",
        constructor_calldata=[
            xoroshiro128.contract_address,
            dairyMaterial.contract_address
        ]
    )

    return starknet, dairyMaterial, bonus, account, operator


@pytest.mark.asyncio
async def test_get_login_time(bonus_factory):
    _, dairyMaterial, bonus, account, _ = bonus_factory

    await signer.send_transaction(account, bonus.contract_address, 'regist_owner', [*to_split_uint(ENS_NAME_INT)])

    execution_info = await bonus.get_login_time(to_split_uint(ENS_NAME_INT)).call()
    print(execution_info.result.last_login_time)


@pytest.mark.asyncio
async def test_check_elapsed_time(bonus_factory):
    _, dairyMaterial, bonus, account, _ = bonus_factory
   
    execution_info = await bonus.check_elapsed_time(to_split_uint(ENS_NAME_INT)).call()
    print(execution_info.result.elapsed_time)
    execution_info = await bonus.check_reward(to_split_uint(ENS_NAME_INT)).call()
    print("check:reward")
    print(execution_info.result.flg)
    assert execution_info.result.flg == 0

@pytest.mark.asyncio
async def test_get_reward(bonus_factory):
    _, dairyMaterial, bonus, account, _ = bonus_factory
    
    accounts = [account.contract_address, account.contract_address, account.contract_address,
                account.contract_address]
    token_ids = [(0, 0), (1, 0), (2, 0), (3, 0)]
    execution_info = await dairyMaterial.balance_of_batch(accounts, token_ids).call()
    assert execution_info.result.res == [0,0,0,0]

    await signer.send_transaction(account, bonus.contract_address, 'get_reward', [*to_split_uint(ENS_NAME_INT), account.contract_address])
    execution_info = await dairyMaterial.balance_of_batch(accounts, token_ids).call()

    print("balance")
    print(execution_info.result.res)

    assert sum(execution_info.result.res) == 0

