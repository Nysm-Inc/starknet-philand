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


    dairyMaterial = await starknet.deploy(
        "contracts/l2/DailyMaterial.cairo",
        constructor_calldata=[
            1,
            4,
            184555836509371486644019136839411173249852705485729074225653387927518275942,
            210616560794178717850935920065495060911188822037429046327979330294206130042,
            187985923959723853589968256655376306670773667376910287781628159691950468714,
            7565166,
        ]
    )

    craftMaterial = await starknet.deploy(
        "contracts/l2/CraftMaterial.cairo",
        constructor_calldata=[
            1,
            4,
            184555836509371486644019136839411173249852705485729074225653387927518275942,
            210616560794178717850935920065495060911188822037429046327979330294206130042,
            187985923959723853589968256655376306670773667376910287781628159691950468714,
            7565166,
        ]
    )

    craft = await starknet.deploy(
        "contracts/l2/Craft.cairo",
        constructor_calldata=[
            dairyMaterial.contract_address,
            craftMaterial.contract_address,
        ]
    )

    return starknet, dairyMaterial, craftMaterial, craft, account, operator


@pytest.mark.asyncio
async def test_craft_soil_2_brick(craft_factory):
    _, dairyMaterial, craftMaterial, craft, account, _ = craft_factory

    execution_info = await dairyMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0
    
    execution_info = await craftMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, dairyMaterial.contract_address, '_mint', [account.contract_address, 0, 0, 4])
    execution_info = await dairyMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, craft.contract_address, 'craft_soil_2_brick', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await dairyMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    

@pytest.mark.asyncio
async def test_craft_brick_2_brickhouse(craft_factory):
    _, _, craftMaterial, craft, account, _ = craft_factory

    execution_info = await craftMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await craftMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, craftMaterial.contract_address, '_mint', [account.contract_address, 0, 0, 3])
    execution_info = await craftMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, craft.contract_address, 'craft_brick_2_brickHouse', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await craftMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0


@pytest.mark.asyncio
async def test_craft_soilAndSeed_2_wood(craft_factory):
    _, dairyMaterial, craftMaterial, craft, account, _ = craft_factory

    execution_info = await dairyMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await dairyMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, dairyMaterial.contract_address, '_mint_batch', [account.contract_address, 2, 0, 0, 2, 0, 2, 1, 1])
    accounts = [account.contract_address,
                account.contract_address]
    token_ids = [(0, 0), (2, 0)]
    execution_info = await dairyMaterial.balance_of_batch(accounts, token_ids).call()
    assert execution_info.result.res == [1,1]

    await signer.send_transaction(account, craft.contract_address, 'craft_soilAndSeed_2_wood', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await dairyMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await dairyMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

@pytest.mark.asyncio
async def test_craft_ironAndWood_2_ironSword(craft_factory):
    _, dairyMaterial, craftMaterial, craft, account, _ = craft_factory

    execution_info = await dairyMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, dairyMaterial.contract_address, '_mint', [account.contract_address, 3, 0, 1])
    execution_info = await dairyMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 1

    # await signer.send_transaction(account, craftMaterial.contract_address, '_mint', [account.contract_address, 2, 0, 1])
    # execution_info = await craftMaterial.balance_of(account.contract_address, (2, 0)).call()
    # assert execution_info.result.res == 1

    await signer.send_transaction(account, craft.contract_address, 'craft_ironAndWood_2_ironSword', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await dairyMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0


@pytest.mark.asyncio
async def test_craft_iron_2_steel(craft_factory):
    _, dairyMaterial, craftMaterial, craft, account, _ = craft_factory

    execution_info = await dairyMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftMaterial.balance_of(account.contract_address, (4, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, dairyMaterial.contract_address, '_mint', [account.contract_address, 3, 0, 3])
    execution_info = await dairyMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 3

    await signer.send_transaction(account, craft.contract_address, 'stake_iron_2_steel', [account.contract_address])
    
    execution_info = await dairyMaterial.balance_of(account.contract_address, (3, 0)).call()
    assert execution_info.result.res == 2

    await signer.send_transaction(account, craft.contract_address, 'craft_iron_2_steel', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (4, 0)).call()
    assert execution_info.result.res == 0


@pytest.mark.asyncio
async def test_craft_oil_2_plastic(craft_factory):
    _, dairyMaterial, craftMaterial, craft, account, _ = craft_factory

    execution_info = await dairyMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, dairyMaterial.contract_address, '_mint', [account.contract_address, 1, 0, 1])
    execution_info = await dairyMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, craft.contract_address, 'craft_oil_2_plastic', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (5, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await dairyMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0


@pytest.mark.asyncio
async def test_craft_plasticAndSteel_2_computer(craft_factory):
    _, _, craftMaterial, craft, account, _ = craft_factory

    execution_info = await craftMaterial.balance_of(account.contract_address, (4, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftMaterial.balance_of(account.contract_address, (5, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, craftMaterial.contract_address, '_mint_batch', [account.contract_address, 2, 4, 0, 5, 0, 2, 1, 1])
    accounts = [account.contract_address,
                account.contract_address]
    token_ids = [(4, 0), (5, 0)]
    execution_info = await craftMaterial.balance_of_batch(accounts, token_ids).call()
    assert execution_info.result.res == [1, 2]

    await signer.send_transaction(account, craft.contract_address, 'craft_plasticAndSteel_2_computer', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (6, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await craftMaterial.balance_of(account.contract_address, (4, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftMaterial.balance_of(account.contract_address, (5, 0)).call()
    assert execution_info.result.res == 0


@pytest.mark.asyncio
async def test_craft_computer_2_electronicsStore(craft_factory):
    _, _, craftMaterial, craft, account, _ = craft_factory

    execution_info = await craftMaterial.balance_of(account.contract_address, (6, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, craftMaterial.contract_address, '_mint', [account.contract_address, 6, 0, 3])
    execution_info = await craftMaterial.balance_of(account.contract_address, (6, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, craft.contract_address, 'craft_computer_2_electronicsStore', [account.contract_address])
    execution_info = await craftMaterial.balance_of(account.contract_address, (7, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await craftMaterial.balance_of(account.contract_address, (6, 0)).call()
    assert execution_info.result.res == 0
