
import os
import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import str_to_felt, felt_to_str,Signer

# constants
NUM_SIGNING_ACCOUNTS = 2
DUMMY_PRIVATE = 12345678987654321
L1_ADDRESS = 0x1
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
            "contracts/l2/Account.cairo",
            constructor_calldata=[signer.public_key]
        )

        accounts.append(account)

        print(f'Account {i} is: {hex(account.contract_address)}')

    return starknet, accounts

@pytest.fixture(scope='module')
async def philand_factory(account_factory):
    starknet, accounts = account_factory
    # Deploy
    print(f'Deploying philand...')
    philand = await starknet.deploy("contracts/l2/philand.cairo")
    print(f'philand is: {hex(philand.contract_address)}')
    return starknet, philand, accounts


@pytest.mark.asyncio
async def test_create_philand(philand_factory):
    # Start with freshly spawned game
    _, philand, accounts = philand_factory

    # grid_x = 0 , grid_y = 0 , object = [0]*64
    x_y_objects = [0]*66
    x_y_objects[32] =1
    await signers[0].send_transaction(
        account=accounts[0],
        to=philand.contract_address,
        selector_name='create_philand',
        calldata=x_y_objects)

    # 
    response = await philand.view_philand(accounts[0].contract_address).call()
    (im) = response.result
    await view([im])
    print('Above is the newly created your philand')


@pytest.mark.asyncio
async def test_create_gird(
    philand_factory
):
    

    starknet, philand, accounts = philand_factory

    grid_x=0
    grid_y=0
    response = await philand.view_grid(grid_x, grid_y).call()
    print('Claim Grid(0,0) by zak3939.eth...')
    await starknet.send_message_to_l2(
        from_address=L1_ADDRESS,
        to_address=philand.contract_address,
        selector="create_grid",
        payload=[
            grid_x,
            grid_y,
            str_to_felt("zak3939.eth")
        ],
    )
    response = await philand.view_grid(grid_x, grid_y).call()
    print(f'{felt_to_str(response.result.owner)} is Grid({grid_x},{grid_y}) owner')

async def view(images):
    # For an philand appearance:
    # .replace('1','■ ').replace('0','. ')
    for index, image in enumerate(images):
        print(f"image_{index}:")
        print(format(image[0:7]).replace('1', '■ ').replace('0', '. '))
        print(format(image[7:14]).replace('1', '■ ').replace('0', '. '))
        print(format(image[14:21]).replace('1', '■ ').replace('0', '. '))
        print(format(image[21:28]).replace('1', '■ ').replace('0', '. '))
        print(format(image[28:35]).replace('1', '■ ').replace('0', '. '))
        print(format(image[35:42]).replace('1', '■ ').replace('0', '. '))
        print(format(image[42:49]).replace('1', '■ ').replace('0', '. '))
        print(format(image[49:56]).replace('1', '■ ').replace('0', '. '))
        print(format(image[56:63]).replace('1', '■ ').replace('0', '. '))
