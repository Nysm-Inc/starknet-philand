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
async def craft_factory():
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

    craft = await starknet.deploy(
        "contracts/l2/Craft.cairo",
        constructor_calldata=[
            material.contract_address
        ]
    )

    return starknet, material, craft, account, operator


@pytest.mark.asyncio
async def test_craft(craft_factory):
    _, material, craft, account, _ = craft_factory
    execution_info = await material.balance_of(account.contract_address, (1, 0)).call()
    print(execution_info.result.res)
    assert execution_info.result.res == 0

    await signer.send_transaction(account, material.contract_address, '_mint', [account.contract_address, 1, 0, 4])
    execution_info = await material.balance_of(account.contract_address, (1, 0)).call()
    print(execution_info.result.res)
    assert execution_info.result.res == 4

    await signer.send_transaction(account, craft.contract_address, 'soil_2_brick', [account.contract_address])
    execution_info = await material.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1
    
