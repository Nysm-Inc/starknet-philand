
import os
from secrets import token_hex
import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import str_to_felt, felt_to_str, Signer, uint, str_to_felt_array, to_split_uint
from constants import ACCOUNT_FILE, DUMMY_ADDRESS, DUMMY_PRIVATE, ENS_NAME_INT, L1_ADDRESS, NUM_SIGNING_ACCOUNTS, PHILAND_FILE, PHIOBJECT_FILE, DUMMY_ENS_NAME_INT



signers = []

TOKENURI = "https://dweb.link/ipfs/bafyreiffxtdf5bobkwevesevvnevvug4i4qeodvzhseknoepbafhx7yn3e/metadata.json"
TOKENURI3 = "https://dweb.link/ipfs/bafyreidw5fl2izaqblqisq6wsmynaezf3rdaq3ctf5iqylkjfaftsc5tey/metadata.json"


###########
# HELPERS #
###########

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
    print(f'Deploying object...')
    object = await starknet.deploy(source=PHIOBJECT_FILE,
                                   constructor_calldata=[accounts[0].contract_address])
    print(f'object is: {hex(object.contract_address)}')
    return starknet, object, accounts

@pytest.fixture(scope='module')
async def philand_factory(object_factory):
    starknet, object, accounts = object_factory
    # token_uri_felt_array = str_to_felt_array(TOKENURI)
    # Deploy
    print(f'Deploying philand...')
    
    philand = await starknet.deploy(source=PHILAND_FILE,
    constructor_calldata=[
        object.contract_address,
        L1_ADDRESS
    ])

    # print(f'philand is: {hex(philand.contract_address)}')
    # token_id=1
    # execution_info = await object.tokenURI(to_split_uint(token_id)).call()
    # token_uri = ""
    # for tu in execution_info.result.token_uri:
    #     token_uri += felt_to_str(tu)
    # print(token_uri)
    return starknet, philand, object, accounts


@pytest.mark.asyncio
async def test_create_philand(
    philand_factory
):
    starknet, philand,_, accounts = philand_factory
    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="create_philand",
        payload=[
            *to_split_uint(ENS_NAME_INT)
        ],
    )
    number_of_philand = await philand.view_number_of_philand().call()
    assert number_of_philand.result.res == 1
    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)
    # (im) = response.result
    # await view([im])
    print('Above is the newly created your philand')

@pytest.mark.asyncio
async def test_claim_starter_object(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory
    payload = [*to_split_uint(ENS_NAME_INT),accounts[0].contract_address]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='claim_starter_object',
        calldata=payload)

    account_check = [accounts[0].contract_address,
                accounts[0].contract_address, accounts[0].contract_address,
                accounts[0].contract_address, accounts[0].contract_address]
    token_ids = [(1, 0), (2, 0), (3, 0),(4,0),(5,0)]
    response=await object.balance_of_batch(account_check, token_ids).call()
    print(response.result.res)
    assert response.result.res == [1,1,1,1,1]
    assert len(response.result.res) == len(token_ids)


# @pytest.mark.asyncio
# async def test_create_object(
#     philand_factory
# ):
#     _, philand, object, accounts = philand_factory
    
#     token_id = 2    
#     response = await philand.get_object_index().call()
#     print(f'Current object_id:{response.result.current_index}')
#     print('New Object is creating...')
    
#     token_uri_felt_array = str_to_felt_array(TOKENURI2)
#     payload = [object.contract_address, *to_split_uint(token_id),
#                 len(token_uri_felt_array),*token_uri_felt_array]
#     await signers[0].send_transaction(
#         account=accounts[0],
#         to=philand.contract_address,
#         selector_name='create_l2_object',
#         calldata=payload)

#     response = await philand.get_object_index().call()
#     print(f'Current object_id:{response.result.current_index}')
#     response = await philand.view_object(response.result.current_index).call()
#     print(f'Contract address:{hex(response.result.contract_address)}')
#     print(f'token_id:{response.result.token_id}')
#     print(type(response.result.token_id))
#     execution_info = await object.tokenURI(response.result.token_id).call()
#     token_uri = ""
#     for tu in execution_info.result.token_uri:
#         token_uri += felt_to_str(tu)
#     print(token_uri)
#     assert execution_info.result.token_uri == str_to_felt_array(TOKENURI2)

@pytest.mark.asyncio
async def test_write_link(
    philand_factory
):
    _, philand, _, accounts = philand_factory

    print('New link is creating...')
    payload = [*to_split_uint(ENS_NAME_INT), 0, 2, DUMMY_ADDRESS,
               *to_split_uint(DUMMY_ENS_NAME_INT)]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_link',
        calldata=payload)

    response = await philand.view_parcel(to_split_uint(ENS_NAME_INT), 0, 2).call()
    print(response.result.link)
    assert response.result.link.contract_address == DUMMY_ADDRESS

@pytest.mark.asyncio
async def test_write_setting(
    philand_factory
):
    _, philand, _, accounts = philand_factory

    response = await philand.view_setting(to_split_uint(ENS_NAME_INT)).call()
    print(f'Current setting land:{response.result.land_type}')
    print(f'Creating land at:{response.result.created_at}')
    print(f'Land spawn:{response.result.spawn_link}')

    print('New setting is creating...')
    payload = [*to_split_uint(ENS_NAME_INT), 1]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_setting_landtype',
        calldata=payload)

    payload = [*to_split_uint(ENS_NAME_INT), 2, 2]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_setting_spawn_link',
        calldata=payload)

    response = await philand.view_setting(to_split_uint(ENS_NAME_INT)).call()
    print(f'Current link_num:{response.result.land_type}')
    assert response.result.land_type == 1

    print(f'Current link_num:{response.result.spawn_link}')
    assert response.result.spawn_link == (2,2)

@pytest.mark.asyncio
async def test_write_object_to_parcel(
    philand_factory
):
    starknet, philand, _, accounts = philand_factory

    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="create_philand",
        payload=[
            *to_split_uint(ENS_NAME_INT)
        ],
    )
    
    print('New Object is Creating by L1...')
    lootContract = 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7
    token_id = 13
    payload = [*to_split_uint(ENS_NAME_INT), lootContract,
               *to_split_uint(token_id)]

    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="claim_l1_object",
        payload=payload,
    )
 

    print("New Object is writing to parcel...")
    payload = [7, 7, *to_split_uint(ENS_NAME_INT),
               0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7,1,0]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_object_to_parcel',
        calldata=payload)

    response = await philand.view_parcel(to_split_uint(ENS_NAME_INT), 7, 7).call()
    print(
        f'Parcel(7,7):object{response.result.contract_address}:{response.result.token_id}')
    print(
        f'Parcel(7,7):link:{response.result.link}')
    

        

@pytest.mark.asyncio
async def test_batch_write_object_to_parcel(
    philand_factory
):
    starknet, philand, object, accounts = philand_factory

    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="create_philand",
        payload=[
            *to_split_uint(ENS_NAME_INT)
        ],
    )

    token_id = 1
    print('New Object is creating...')

    token_uri_felt_array = str_to_felt_array(TOKENURI3)
    payload = [object.contract_address, *to_split_uint(token_id),
               len(token_uri_felt_array), *token_uri_felt_array]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='create_l2_object',
        calldata=payload)

    print("Batch write New Object is writing to parcel...")
    payload = [4,5,3,2,1, 
                4,7,6,5,4,
               *to_split_uint(ENS_NAME_INT),
               4, object.contract_address, 1, 0, object.contract_address, 1, 0, object.contract_address, 1, 0, object.contract_address, 1, 0]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='batch_write_object_to_parcel',
        calldata=payload)

    response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
    print(response.result)

    # (im) = response.result
    # await view([im])
    print('Above is the updated your philand')
    response = await philand.view_parcel(to_split_uint(ENS_NAME_INT), 5, 7).call()
    print(
        f'Parcel(7,7):object{response.result.contract_address}:{response.result.token_id}')


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


async def view2(images):
    # For an philand appearance:
    # .replace('1','■ ').replace('0','. ')
    for index, image in enumerate(images):
        print(f"your links:")
        print(format(image[0:8]).replace('1', '■ ').replace('0', '. '))
        print(format(image[8:16]).replace('1', '■ ').replace('0', '. '))
        print(format(image[16:24]).replace('1', '■ ').replace('0', '. '))
        print(format(image[24:32]).replace('1', '■ ').replace('0', '. '))
        print(format(image[32:40]).replace('1', '■ ').replace('0', '. '))
        print(format(image[40:48]).replace('1', '■ ').replace('0', '. '))
        print(format(image[48:56]).replace('1', '■ ').replace('0', '. '))
        print(format(image[56:64]).replace('1', '■ ').replace('0', '. '))
