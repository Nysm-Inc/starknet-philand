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

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def wrap_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        "contracts/openzeppelin/account/Account.cairo",
        constructor_calldata=[signer.public_key]
    )
    operator = await starknet.deploy(
        "contracts/openzeppelin/account/Account.cairo",
        constructor_calldata=[other.public_key]
    )

    primitiveMaterial = await starknet.deploy(
        "contracts/l2/PrimitiveMaterial.cairo",
        constructor_calldata=[
            account.contract_address
        ]
    )
    craftedMaterial = await starknet.deploy(
        "contracts/l2/CraftedMaterial.cairo",
        constructor_calldata=[
            account.contract_address
        ]
    )
    wrapPrimitiveMaterial = await starknet.deploy(
        "contracts/l2/WrapPrimitiveMaterial.cairo",
        constructor_calldata=[
            account.contract_address
        ]
    )
    wrapCraftedMaterial = await starknet.deploy(
        "contracts/l2/WrapCraftedMaterial.cairo",
        constructor_calldata=[
            account.contract_address
        ]
    )
    wrap = await starknet.deploy(
        "contracts/l2/Wrap.cairo",
        constructor_calldata=[
            primitiveMaterial.contract_address,
            craftedMaterial.contract_address,
            wrapPrimitiveMaterial.contract_address,
            wrapCraftedMaterial.contract_address
        ]
    )
    return starknet, primitiveMaterial, craftedMaterial, wrapPrimitiveMaterial, wrapCraftedMaterial,wrap, account, operator


@pytest.mark.asyncio
async def test_wrap_primitive_material(wrap_factory):
    _, primitiveMaterial, _, wrapPrimitiveMaterial, _, wrap, account, _ = wrap_factory

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, primitiveMaterial.contract_address, '_mint', [account.contract_address, 0, 0, 4])
    execution_info = await primitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, wrap.contract_address, 'wrap_primitive_material', [account.contract_address, 0, 0,4])

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4


@pytest.mark.asyncio
async def test_unwrap_primitive_material(wrap_factory):
    _, primitiveMaterial, _, wrapPrimitiveMaterial, _, wrap, account, _ = wrap_factory

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, wrap.contract_address, 'unwrap_primitive_material', [account.contract_address, 0, 0, 4])

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4


@pytest.mark.asyncio
async def test_batch_wrap_primitive_material(wrap_factory):
    _, primitiveMaterial, _, wrapPrimitiveMaterial, _, wrap, account, _ = wrap_factory

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, primitiveMaterial.contract_address, '_mint_batch', [account.contract_address, 2, 1, 0, 2, 0, 2, 1, 1])
    execution_info = await primitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1
    execution_info = await primitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, wrap.contract_address, 'batch_wrap_primitive_material', [account.contract_address, 2, 1, 0, 2, 0, 2, 1, 1])

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1


@pytest.mark.asyncio
async def test_batch_unwrap_primitive_material(wrap_factory):
    _, primitiveMaterial, _, wrapPrimitiveMaterial, _, wrap, account, _ = wrap_factory

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, wrap.contract_address, 'batch_unwrap_primitive_material', [account.contract_address, 2, 1, 0, 2, 0, 2, 1, 1])

    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0
    execution_info = await wrapPrimitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await primitiveMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

@pytest.mark.asyncio
async def test_wrap_crafted_material(wrap_factory):
    _, _, craftedMaterial, _, wrapCraftedMaterial, wrap, account, _ = wrap_factory

    execution_info = await craftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, craftedMaterial.contract_address, '_mint', [account.contract_address, 0, 0, 4])
    execution_info = await craftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, wrap.contract_address, 'wrap_crafted_material', [account.contract_address, 0, 0, 4])

    execution_info = await craftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4


@pytest.mark.asyncio
async def test_unwrap_crafted_material(wrap_factory):
    _, _, craftedMaterial, _, wrapCraftedMaterial, wrap, account, _ = wrap_factory

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4

    await signer.send_transaction(account, wrap.contract_address, 'unwrap_crafted_material', [account.contract_address, 0, 0, 4])

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftedMaterial.balance_of(account.contract_address, (0, 0)).call()
    assert execution_info.result.res == 4


@pytest.mark.asyncio
async def test_batch_wrap_crafted_material(wrap_factory):
    _, _, craftedMaterial, _, wrapCraftedMaterial, wrap, account, _ = wrap_factory

    execution_info = await craftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    await signer.send_transaction(account, craftedMaterial.contract_address, '_mint_batch', [account.contract_address, 2, 1, 0, 2, 0, 2, 1, 1])
    execution_info = await craftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1
    execution_info = await craftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, wrap.contract_address, 'batch_wrap_crafted_material', [account.contract_address, 2, 1, 0, 2, 0, 2, 1, 1])

    execution_info = await craftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1


@pytest.mark.asyncio
async def test_batch_unwrap_crafted_material(wrap_factory):
    _, _, craftedMaterial, _, wrapCraftedMaterial, wrap, account, _ = wrap_factory

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1

    await signer.send_transaction(account, wrap.contract_address, 'batch_unwrap_crafted_material', [account.contract_address, 2, 1, 0, 2, 0, 2, 1, 1])

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await wrapCraftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 0

    execution_info = await craftedMaterial.balance_of(account.contract_address, (1, 0)).call()
    assert execution_info.result.res == 1

    execution_info = await craftedMaterial.balance_of(account.contract_address, (2, 0)).call()
    assert execution_info.result.res == 1
