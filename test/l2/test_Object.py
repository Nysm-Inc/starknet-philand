import pytest
import asyncio
import numpy
from starkware.starknet.testing.starknet import Starknet
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.definitions.error_codes import StarknetErrorCode
from utils import Signer, to_split_uint

signer = Signer(123456789987654321)
other = Signer(123456789987654321)


@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def object_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[signer.public_key]
    )
    operator = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[other.public_key]
    )


    object = await starknet.deploy(
        "contracts/l2/Object.cairo",
        constructor_calldata=[
            int.from_bytes("object".encode("ascii"), 'big'), 
            0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599, 
            int.from_bytes("{id}".encode("ascii"), 'big')
        ]
    )
    return starknet, object, account, operator


@pytest.mark.asyncio
async def test_constructor(object_factory):
    _, object, account, _, = object_factory


    # Test URI has been stored when contract was initialized
    asset_namespace = int.from_bytes("object".encode("ascii"), 'big')
    asset_reference = 0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599
    token_id = int.from_bytes("{id}".encode("ascii"), 'big')

    execution_info = await object.uri().call()
    assert execution_info.result.res.asset_namespace == asset_namespace
    assert execution_info.result.res.asset_reference == asset_reference
    assert execution_info.result.res.token_id == token_id
    # assert execution_info.result.res.asset_namespace == (asset_namespace,)
    # assert execution_info.result.res.asset_reference == (asset_reference,)
    # assert execution_info.result.res.token_id == (token_id,)


@pytest.mark.asyncio
async def test_balance_of_batch(object_factory):
    _, object, account, _, = object_factory

    await signer.send_transaction(account, object.contract_address, '_mint_batch', [account.contract_address, 2,1,0, 2,0, 2, 1000, 500])

    accounts = [account.contract_address, account.contract_address, account.contract_address]
    token_ids = [(2,0),(1,0),(1,0)]
    print(*token_ids)
    execution_info = await object.balance_of_batch(accounts, token_ids).call()
    print(execution_info.result.res)
    assert execution_info.result.res == [500, 1000, 1000]
    assert len(execution_info.result.res) == len(token_ids)


@pytest.mark.asyncio
async def test_is_approved(object_factory):
    _, object, account, _, = object_factory

    operator = 123
    approval = 1
    not_boolean_approval = 15

    # test set_approval_for_all with value that is not a boolean
    try:
        await signer.send_transaction(account, object.contract_address, 'set_approval_for_all', [operator, not_boolean_approval])
        assert False
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED

    await signer.send_transaction(account, object.contract_address, 'set_approval_for_all', [operator, approval])
    assert(await object.is_approved_for_all(account.contract_address, operator).call()).result == (1,)

    await signer.send_transaction(account, object.contract_address, 'set_approval_for_all', [operator, 0])
    assert(await object.is_approved_for_all(account.contract_address, operator).call()).result == (0,)


@pytest.mark.asyncio
async def test_transfer_from(object_factory):
    _, object, account, operator = object_factory

    balance_1_of_other = await object.balance_of(operator.contract_address, (1,0)).call()
    balance_1_of_from_address = await object.balance_of(account.contract_address, (1,0)).call()
    assert balance_1_of_other.result.res == 0

    # Test if Other transfers 1 from Account without approval
    try:
        await other.send_transaction(operator, object.contract_address, 'safe_transfer_from', [account.contract_address, operator.contract_address, 1,0, 1])
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED

    # Setting approval
    await signer.send_transaction(account, object.contract_address, 'set_approval_for_all', [operator.contract_address, 1])

    # Test Other transfers 1 from Account after approval
    await other.send_transaction(operator, object.contract_address, 'safe_transfer_from', [account.contract_address, operator.contract_address, 1,0, 1])

    balance_2_of_other = await object.balance_of(operator.contract_address, (1,0)).call()
    assert balance_2_of_other.result.res == balance_1_of_other.result.res + 1
    balance_2_of_from_address = await object.balance_of(account.contract_address, (1,0)).call()
    assert balance_2_of_from_address.result.res == balance_1_of_from_address.result.res - 1

    # Test Other transfers more tokens than current balance
    try:
        await other.send_transaction(operator, object.contract_address, 'safe_transfer_from', [account.contract_address, operator.contract_address, 1,0, balance_1_of_from_address.result.res])
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED

    # Unsetting approval
    await signer.send_transaction(account, object.contract_address, 'set_approval_for_all', [operator.contract_address, 0])


@pytest.mark.asyncio
async def test_transfer_batch_from(object_factory):
    _, object, account, operator = object_factory

    balances_1 = (await object.balance_of_batch([account.contract_address, account.contract_address, operator.contract_address, operator.contract_address], [(1, 0), (2, 0), (1, 0), (2,0)]).call()).result.res
    # amounts to transfer between balances
    amount1 = 50
    amount2 = 25

    operations = [-amount1, -amount2, +amount1, +amount2]
    #  TEST IF OTHER TOOK 1 FROM ACCOUNT WITHOUT APPROVAL
    try:
        await other.send_transaction(operator, object.contract_address, 'safe_batch_transfer_from', [account.contract_address, operator.contract_address, 2,1,0, 2,0, 2, amount1, amount2])
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED

    # SETTING APPROVAL
    await signer.send_transaction(account, object.contract_address, 'set_approval_for_all', [operator.contract_address, 1])
    await other.send_transaction(operator, object.contract_address, 'safe_batch_transfer_from', [account.contract_address, operator.contract_address, 2,1,0, 2,0, 2, amount1, amount2])

    balances_2 = (await object.balance_of_batch([account.contract_address, account.contract_address, operator.contract_address, operator.contract_address], [(1,0),(2,0), (1,0), (2,0)]).call()).result.res
    # Balance 2 = balance 1 with operations made
    assert balances_2 == [x+y for x, y in zip(balances_1, operations)]

    # OTHER TAKE TOO MUCH
    try:
        await other.send_transaction(operator, object.contract_address, 'safe_batch_transfer_from', [account.contract_address, operator.contract_address, 2, 1,0, 2,0, 2, 1000, 1000])
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED

# # To test this function ensure _burn function in contract is set to @external


@pytest.mark.asyncio
async def test_burn(object_factory):
    _, object, account, _, = object_factory
    token_id = 1
    amount_to_burn = 10

    # burn 10 tokens
    balance_before = (await object.balance_of(account.contract_address, to_split_uint(token_id)).call()).result.res
    await signer.send_transaction(account, object.contract_address, '_burn', [account.contract_address, *to_split_uint(token_id), amount_to_burn])
    assert (await object.balance_of(account.contract_address, to_split_uint(token_id)).call()).result.res == balance_before - amount_to_burn

    # try burning too much tokens
    try:
        await signer.send_transaction(account, object.contract_address, '_burn', [account.contract_address, *to_split_uint(token_id), 5000])
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED


@pytest.mark.asyncio
async def test_burn_batch(object_factory):

    _, object, account, operator = object_factory

    balances_1 = (await object.balance_of_batch([account.contract_address, account.contract_address], [to_split_uint(1), to_split_uint(2)]).call()).result.res
    # amounts to transfer between balances
    amount1 = 50
    amount2 = 25

    operations = [-amount1, -amount2]

    await signer.send_transaction(account, object.contract_address, '_burn_batch', [account.contract_address, 2, *to_split_uint(1), *to_split_uint(2), 2, amount1, amount2])

    balances_2 = (await object.balance_of_batch([account.contract_address, account.contract_address], [to_split_uint(1), to_split_uint(2)]).call()).result.res
    # Balance 2 = balance 1 with operations made
    assert balances_2 == [x+y for x, y in zip(balances_1, operations)]

    # Other burns more tokens than current balance
    try:
        await other.send_transaction(account, object.contract_address, '_burn_batch', [account.contract_address, 2, *to_split_uint(1), *to_split_uint(2), 2, 1000, 1000])
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED
