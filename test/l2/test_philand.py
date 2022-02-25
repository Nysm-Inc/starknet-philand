
import os
import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import str_to_felt, felt_to_str,Signer,uint

# constants
NUM_SIGNING_ACCOUNTS = 2
DUMMY_PRIVATE = 12345678987654321
L1_ADDRESS = 0x1
signers = []
ENS_NAME = "zak3939.eth"

L2_CONTRACTS_DIR = os.path.join(os.getcwd(), "contracts/l2")
ACCOUNT_FILE = os.path.join(L2_CONTRACTS_DIR, "Account.cairo")
OBJECT_FILE = os.path.join(L2_CONTRACTS_DIR, "Object.cairo")
PHILAND_FILE = os.path.join(L2_CONTRACTS_DIR, "Philand.cairo")
###########
# HELPERS #
###########
def to_split_uint(a):
    return (a & ((1 << 128) - 1), a >> 128)


def to_uint(a):
    return a[0] + (a[1] << 128)



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
                                       int.from_bytes("object".encode(
                                           "ascii"), 'big'), 0x056bfe4139dd88d0a9ff44e3166cb781e002f052b4884e6f56e51b11bebee599, int.from_bytes("{id}".encode("ascii"), 'big')
                                   ])
    print(f'object is: {hex(object.contract_address)}')
    return starknet, object, accounts

@pytest.fixture(scope='module')
async def philand_factory(object_factory):
    starknet, object, accounts = object_factory
    # Deploy
    print(f'Deploying philand...')
    philand = await starknet.deploy(source=PHILAND_FILE,
    constructor_calldata=[
        object.contract_address,
        L1_ADDRESS,
    ])
    print(f'philand is: {hex(philand.contract_address)}')
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


# @pytest.mark.asyncio
# async def test_create_L1nft_object(
#     philand_factory
# ):
#     _, philand, _, accounts = philand_factory
#     lootContract = 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7
#     tokenid = 13    

#     response = await philand.get_object_index().call()
#     print(f'Current object_id:{response.result.current_index}')
#     print('New Object is creating...')

#     payload = [lootContract, *to_split_uint(tokenid)]
#     await signers[0].send_transaction(
#         account=accounts[0],
#         to=philand.contract_address,
#         selector_name='create_l1nft_object',
#         calldata=payload)

#     response = await philand.view_object(response.result.current_index).call()
#     print(f'Contract address:{hex(response.result.contract_address)}')
#     print(f'tokenid:{response.result.tokenid}')


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
        
