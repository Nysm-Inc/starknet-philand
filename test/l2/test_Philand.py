
import os
from secrets import token_hex
import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import str_to_felt, felt_to_str, Signer, uint, str_to_felt_array, to_split_uint

# constants
NUM_SIGNING_ACCOUNTS = 2
DUMMY_PRIVATE = 12345678987654321
L1_ADDRESS = 0x1
DUMMY_ADDRESS =0x2

signers = []
ENS_NAME = "zak3939.eth"
DUMMY_ENS_NAME = "test.eth"
TOKENURI = "https://dweb.link/ipfs/bafyreiffxtdf5bobkwevesevvnevvug4i4qeodvzhseknoepbafhx7yn3e/metadata.json"
TOKENURI2 = "https://dweb.link/ipfs/bafyreifw4jmfjiouqtvhxvvaoxe7bbhfi5fkgzjeqt5tpvkrvszcx5n3zy/metadata.json"
TOKENURI3 = "https://dweb.link/ipfs/bafyreidw5fl2izaqblqisq6wsmynaezf3rdaq3ctf5iqylkjfaftsc5tey/metadata.json"
L2_CONTRACTS_DIR = os.path.join(os.getcwd(), "contracts/l2")
ACCOUNT_FILE = os.path.join(L2_CONTRACTS_DIR, "Account.cairo")
OBJECT_FILE = os.path.join(L2_CONTRACTS_DIR, "Object.cairo")
PHILAND_FILE = os.path.join(L2_CONTRACTS_DIR, "Philand.cairo")

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
    object = await starknet.deploy(source=OBJECT_FILE,
                                   constructor_calldata=[
                                    #    int.from_bytes("object".encode(
                                    #        "ascii"), 'big'), 0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599, int.from_bytes("{id}".encode("ascii"), 'big')
                                   ])
    print(f'object is: {hex(object.contract_address)}')
    return starknet, object, accounts

@pytest.fixture(scope='module')
async def philand_factory(object_factory):
    starknet, object, accounts = object_factory
    token_uri_felt_array = str_to_felt_array(TOKENURI)
    # Deploy
    print(f'Deploying philand...')
    print(*token_uri_felt_array)
    calldata=[
        object.contract_address,
        L1_ADDRESS,
        len(token_uri_felt_array),
        *token_uri_felt_array
    ]
    philand = await starknet.deploy(source=PHILAND_FILE,
    constructor_calldata=[
        object.contract_address,
        L1_ADDRESS,
        len(token_uri_felt_array), 
        *token_uri_felt_array
    ])
    print(calldata)
    print(f'philand is: {hex(philand.contract_address)}')
    tokenid=1
    execution_info = await object.tokenURI(to_split_uint(tokenid)).call()
    token_uri = ""
    for tu in execution_info.result.token_uri:
        token_uri += felt_to_str(tu)
    print(token_uri)
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
            str_to_felt(ENS_NAME)
        ],
    )
    response = await philand.view_philand(accounts[0].contract_address).call()
    (im) = response.result
    await view([im])
    print('Above is the newly created your philand')


@pytest.mark.asyncio
async def test_create_object(
    philand_factory
):
    _, philand, object, accounts = philand_factory
    
    tokenid = 2    
    response = await philand.get_object_index().call()
    print(f'Current object_id:{response.result.current_index}')
    print('New Object is creating...')
    
    token_uri_felt_array = str_to_felt_array(TOKENURI2)
    payload = [object.contract_address, *to_split_uint(tokenid),
                len(token_uri_felt_array),*token_uri_felt_array]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='create_l2_object',
        calldata=payload)

    response = await philand.get_object_index().call()
    print(f'Current object_id:{response.result.current_index}')
    response = await philand.view_object(response.result.current_index).call()
    print(f'Contract address:{hex(response.result.contract_address)}')
    print(f'tokenid:{response.result.tokenid}')
    print(type(response.result.tokenid))
    execution_info = await object.tokenURI(response.result.tokenid).call()
    token_uri = ""
    for tu in execution_info.result.token_uri:
        token_uri += felt_to_str(tu)
    print(token_uri)
    assert execution_info.result.token_uri == str_to_felt_array(TOKENURI2)

@pytest.mark.asyncio
async def test_write_newlink(
    philand_factory
):
    _, philand, _, accounts = philand_factory

    response = await philand.view_link_num(str_to_felt(ENS_NAME)).call()
    print(f'Current link_num:{response.result.num}')
    print('New link is creating...')
    payload = [str_to_felt(ENS_NAME), 0, 2, DUMMY_ADDRESS,
               str_to_felt(DUMMY_ENS_NAME)]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_newlink',
        calldata=payload)
    response = await philand.view_link_num(str_to_felt(ENS_NAME)).call()
    print(f'Current link_num:{response.result.num}')
    response = await philand.view_link(str_to_felt(ENS_NAME), response.result.num).call()
    print(response.result.link)


@pytest.mark.asyncio
async def test_write_setting(
    philand_factory
):
    _, philand, _, accounts = philand_factory

    response = await philand.view_setting(str_to_felt(ENS_NAME)).call()
    print(f'Current setting land:{response.result.land_type}')
    print(f'Creating land:{response.result.created_at}')
    print('New link is creating...')
    payload = [str_to_felt(ENS_NAME), 1]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_setting',
        calldata=payload)
    response = await philand.view_setting(str_to_felt(ENS_NAME)).call()
    print(f'Current link_num:{response.result.land_type}')
    assert response.result.land_type == 1

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
            str_to_felt(ENS_NAME)
        ],
    )
    
    response = await philand.get_object_index().call()
    print(f'Current object_id:{response.result.current_index}')
    print('New Object is Creating by L1...')
    lootContract = 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7
    tokenid = 13
    payload = [str_to_felt(ENS_NAME),lootContract, *to_split_uint(tokenid)]

    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="claim_l1_object",
        payload=payload,
    )
    response = await philand.get_object_index().call()
    print(f'Current object_id:{response.result.current_index}')

    print("New Object is writing to parcel...")
    payload = [7, 7, str_to_felt(ENS_NAME), 1]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='write_object_to_parcel',
        calldata=payload)

    response = await philand.view_philand(str_to_felt(ENS_NAME)).call()
    (im) = response.result
    await view([im])
    print('Above is the updated your philand')

    response = await philand.view_parcel(str_to_felt(ENS_NAME),7,7).call()
    print(
        f'Parcel(7,7):{response.result.contract_address}:{response.result.tokenid}')
    print()
    

        

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
            str_to_felt(ENS_NAME)
        ],
    )

    tokenid = 1
    response = await philand.get_object_index().call()
    print(f'Current object_id:{response.result.current_index}')
    print('New Object is creating...')

    token_uri_felt_array = str_to_felt_array(TOKENURI3)
    payload = [object.contract_address, *to_split_uint(tokenid),
               len(token_uri_felt_array), *token_uri_felt_array]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='create_l2_object',
        calldata=payload)

    response = await philand.get_object_index().call()
    created_object_id = response.result.current_index
    print(f'Current object_id:{created_object_id}')

    print("Batch write New Object is writing to parcel...")
    payload = [4,5,3,2,1, 
                4,7,6,5,4,
                str_to_felt(ENS_NAME), 
                4,1, created_object_id, 1, created_object_id]
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='batch_write_object_to_parcel',
        calldata=payload)

    response = await philand.view_philand(str_to_felt(ENS_NAME)).call()
    (im) = response.result
    await view([im])
    print('Above is the updated your philand')


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
