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

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def login_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[signer.public_key]
    )
    operator = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[other.public_key]
    )


    material = await starknet.deploy(
        "contracts/l2/Material.cairo",
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

    login = await starknet.deploy(
        "contracts/l2/Login.cairo",
        constructor_calldata=[
            material.contract_address
        ]
    )

    return starknet,material,login, account, operator


@pytest.mark.asyncio
async def test_get_login_time(login_factory):
    _, material, login, account, _ = login_factory

    await signer.send_transaction(account, login.contract_address, 'regist_owner', [str_to_felt(ENS_NAME)])

    execution_info = await login.get_login_time(str_to_felt(ENS_NAME)).call()
    print(execution_info.result.last_login_time)


@pytest.mark.asyncio
async def test_check_elapsed_time(login_factory):
    _, material, login, account, _ = login_factory
   
    execution_info = await login.check_elapsed_time(str_to_felt(ENS_NAME)).call()
    print(execution_info.result.elapsed_time)
    execution_info = await login.check_reward(str_to_felt(ENS_NAME)).call()
    print("check:reward")
    print(execution_info.result.flg)
    assert execution_info.result.flg == 0

@pytest.mark.asyncio
async def test_get_reward(login_factory):
    _, material, login, account, _ = login_factory
    execution_info = await material.balance_of(account.contract_address, (1, 0)).call()
    print(execution_info.result.res)
    assert execution_info.result.res == 0
    await signer.send_transaction(account, login.contract_address, 'get_reward', [str_to_felt(ENS_NAME),account.contract_address])
    print(account.contract_address)
    execution_info = await material.balance_of(account.contract_address, (1,0)).call()
    print("balance")
    print(execution_info.result.res)

    assert execution_info.result.res == 0

