from secrets import token_hex
import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.definitions.error_codes import StarknetErrorCode
from constants import ACCOUNT_FILE, DUMMY_ADDRESS, DUMMY_PRIVATE, ENS_NAME_INT, L1_ADDRESS, NUM_SIGNING_ACCOUNTS, PHI_FILE, PHIOBJECT_FILE
from utils import str_to_felt, felt_to_str, Signer, uint, str_to_felt_array, to_split_uint

signers = []


@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def account_factory():
    # Initialize network
    starknet = await Starknet.empty()
    accounts = []
    print(f'Deploying {NUM_SIGNING_ACCOUNTS} accounts...')
    for i in range(NUM_SIGNING_ACCOUNTS):
        signer = Signer(DUMMY_PRIVATE + i)
        signers.append(signer)
        account = await starknet.deploy(
            source=ACCOUNT_FILE,
            constructor_calldata=[signer.public_key]
        )

        accounts.append(account)

        print(f'Account {i} is: {hex(account.contract_address)}')

    return starknet, accounts


@pytest.fixture(scope='module')
async def object_factory(account_factory):
    starknet, accounts = account_factory
    # Deploy
    print(f'Deploying phi object contract...')
    object = await starknet.deploy(source=PHIOBJECT_FILE,
                                   constructor_calldata=[accounts[0].contract_address])
    await signers[0].send_transaction(accounts[0], object.contract_address, '_mint_batch', [accounts[0].contract_address, 4, 0, 0, 1, 0, 2, 0, 3,0,4, 1, 1, 1, 1])
    await signers[0].send_transaction(accounts[0], object.contract_address, 'set_size', [0, 0, 1, 2, 1])
    await signers[0].send_transaction(accounts[0], object.contract_address, 'set_size', [1, 0, 4, 2, 1])
    await signers[0].send_transaction(accounts[0], object.contract_address, 'set_size', [2, 0, 3, 3, 1])
    await signers[0].send_transaction(accounts[0], object.contract_address, 'set_size', [3, 0, 1, 1, 1])
    
    print(f'phi object is: {hex(object.contract_address)}')
    
    return starknet, object, accounts

@pytest.fixture(scope='module')
async def philand_factory(object_factory):
    starknet, object, accounts = object_factory
    # Deploy
    print(f'Deploying philand...')
    philand = await starknet.deploy(source=PHI_FILE,
    constructor_calldata=[
        object.contract_address,
        L1_ADDRESS,
    ])
    print(f'phi contract address is: {hex(philand.contract_address)}')
    return starknet, philand, object, accounts

@pytest.mark.asyncio
async def test_create_philand(
    philand_factory
):
    starknet, philand, _, accounts = philand_factory
    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="create_philand",
        payload=[
            *to_split_uint(ENS_NAME_INT), accounts[1].contract_address
        ],
    )
    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)
    print('Above is the newly created your philand')


@pytest.mark.asyncio
async def test_claim_starter_object(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory
    payload = [*to_split_uint(ENS_NAME_INT)]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='claim_starter_object',
        calldata=payload)

    account_check = [accounts[1].contract_address,
                     accounts[1].contract_address, accounts[1].contract_address,
                     accounts[1].contract_address, accounts[1].contract_address]
    token_ids = [(1, 0), (2, 0), (3, 0), (4, 0), (5, 0)]
    response = await object.balance_of_batch(account_check, token_ids).call()
    print(response.result.res)
    assert response.result.res == [1, 1, 1, 1, 1]
    assert len(response.result.res) == len(token_ids)


@pytest.mark.asyncio
async def test_deposit_object(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory

    await signers[1].send_transaction(
        account=accounts[1],
        to=object.contract_address,
        selector_name='set_approval_for_all',
        calldata=[philand.contract_address,1])

    token_id = 1
    payload = [*to_split_uint(ENS_NAME_INT),
               object.contract_address, *to_split_uint(token_id)]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='deposit_object',
        calldata=payload)

    response = await philand.check_deposit_state(to_split_uint(ENS_NAME_INT), object.contract_address, to_split_uint(token_id)).call()
    assert response.result.current_state == 1

@pytest.mark.asyncio
async def test_write_object(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory
    token_id=0
    payload = [*to_split_uint(ENS_NAME_INT), 2, 2,
               object.contract_address, *to_split_uint(token_id)]

    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='write_object_to_land',
        calldata=payload)
    


@pytest.mark.asyncio
async def test_write_object2(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory

    token_id = 1
    payload = [*to_split_uint(ENS_NAME_INT), 4, 4,
               object.contract_address, *to_split_uint(token_id)]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='write_object_to_land',
        calldata=payload)

@pytest.mark.asyncio
async def test_write_object_check_collision(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory

    token_id = 2
    payload = [*to_split_uint(ENS_NAME_INT), 1, 1,
               object.contract_address, *to_split_uint(token_id)]
    try:
        await signers[1].send_transaction(
            account=accounts[1],
            to=philand.contract_address,
            selector_name='write_object_to_land',
            calldata=payload)
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED
    
    token_id = 3
    payload = [*to_split_uint(ENS_NAME_INT), 9, 9,
               object.contract_address, *to_split_uint(token_id)]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='write_object_to_land',
        calldata=payload)

    payload = [*to_split_uint(ENS_NAME_INT), 10, 10,
               object.contract_address, *to_split_uint(token_id)]
    try:
        await signers[1].send_transaction(
            account=accounts[1],
            to=philand.contract_address,
            selector_name='write_object_to_land',
            calldata=payload)
    except StarkException as err:
        _, error = err.args
        assert error['code'] == StarknetErrorCode.TRANSACTION_FAILED

    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)
    payload = [*to_split_uint(ENS_NAME_INT),0]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='remove_object_from_land',
        calldata=payload)
    print("removed object_id=0")
    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)

    token_id = 2
    payload = [*to_split_uint(ENS_NAME_INT), 1, 1,
               object.contract_address, *to_split_uint(token_id)]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='write_object_to_land',
        calldata=payload)
    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)


@pytest.mark.asyncio
async def test_get_user_philand_object(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory
    print("test_get_user_philand_object")
    response = await philand.get_user_philand_object(to_split_uint(ENS_NAME_INT), 0).call()
    print(response.result.res)
    response = await philand.get_user_philand_object(to_split_uint(ENS_NAME_INT), 1).call()
    print(response.result.res)
    response = await philand.get_user_philand_object(to_split_uint(ENS_NAME_INT), 2).call()
    print(response.result.res)
    response = await philand.get_user_philand_object(to_split_uint(ENS_NAME_INT), 3).call()
    print(response.result.res)


@pytest.mark.asyncio
async def test_batch_remove_object_from_land(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory

    payload = [*to_split_uint(ENS_NAME_INT), 3,1,2,3]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='batch_remove_object_from_land',
        calldata=payload)
    response = await philand.get_user_philand_object(to_split_uint(ENS_NAME_INT), 3).call()
    print(response.result.res)


@pytest.mark.asyncio
async def test_batch_write_object_to_land(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory
    
    payload = [*to_split_uint(ENS_NAME_INT), 
               2, 2, 1,
               2, 5, 7,
               2,object.contract_address, object.contract_address, 
               2,*to_split_uint(0), *to_split_uint(1)]
    await signers[1].send_transaction(
        account=accounts[1],
        to=philand.contract_address,
        selector_name='batch_write_object_to_land',
        calldata=payload)
    response = await philand.get_user_philand_object(to_split_uint(ENS_NAME_INT), 3).call()
    print(response.result.res)


@pytest.mark.asyncio
async def test_get_user_philand_object(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory
    print("test_get_user_philand_object")
    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)

###########
# HELPERS #
###########
async def view(images):
    # For an philand appearance:
    # .replace('1','■ ').replace('0','. ')
    for index, image in enumerate(images):
        print(f"your philand:")
        print(format(image[0:8]).replace('1', '■ ').replace('0', '. '))
        print(format(image[8:16]).replace('1', '■ ').replace('0', '. '))
        print(format(image[16:24]).replace('1', '■ ').replace('0', '. '))
        print(format(image[24:32]).replace('1', '■ ').replace('0', '. '))
        print(format(image[32:40]).replace('1', '■ ').replace('0', '. '))
        print(format(image[40:48]).replace('1', '■ ').replace('0', '. '))
        print(format(image[48:56]).replace('1', '■ ').replace('0', '. '))
        print(format(image[56:64]).replace('1', '■ ').replace('0', '. '))

