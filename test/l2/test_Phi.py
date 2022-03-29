
# import os
# from secrets import token_hex
# import pytest
# import asyncio
# from starkware.starknet.testing.starknet import Starknet
# from utils import str_to_felt, felt_to_str, Signer, uint, str_to_felt_array, to_split_uint

# # constants
# NUM_SIGNING_ACCOUNTS = 2
# DUMMY_PRIVATE = 12345678987654321
# L1_ADDRESS = 0x1
# DUMMY_ADDRESS =0x2

# signers = []
# ENS_NAME = "zak3939.eth"

# L2_CONTRACTS_DIR = os.path.join(os.getcwd(), "contracts/l2")

# ACCOUNT_FILE = os.path.join(L2_CONTRACTS_DIR, "Account.cairo")
# OBJECT_FILE = os.path.join(L2_CONTRACTS_DIR, "PhiObject.cairo")
# PHILAND_FILE = os.path.join(L2_CONTRACTS_DIR, "Phi.cairo")
# ENS_NAME_INT = 5354291560282261680205140228934436588969903936754548205611172710617586860032
# DUMMY_ENS_NAME_INT = 3333333
# ###########
# # HELPERS #
# ###########

# @pytest.fixture(scope='module')
# def event_loop():
#     return asyncio.new_event_loop()


# @pytest.fixture(scope='module')
# async def account_factory():
#     # Initialize network
#     starknet = await Starknet.empty()
#     accounts = []
#     print(f'Deploying {NUM_SIGNING_ACCOUNTS} accounts...')
#     for i in range(NUM_SIGNING_ACCOUNTS):
#         signer = Signer(DUMMY_PRIVATE + i)
#         signers.append(signer)
#         account = await starknet.deploy(
#             source=ACCOUNT_FILE,
#             constructor_calldata=[signer.public_key]
#         )

#         accounts.append(account)

#         print(f'Account {i} is: {hex(account.contract_address)}')

#     return starknet, accounts


# @pytest.fixture(scope='module')
# async def object_factory(account_factory):
#     starknet, accounts = account_factory
#     # Deploy
#     print(f'Deploying phi object contract...')
#     object = await starknet.deploy(source=OBJECT_FILE,
#                                    constructor_calldata=[])
#     print(f'phi object is: {hex(object.contract_address)}')
#     return starknet, object, accounts

# @pytest.fixture(scope='module')
# async def philand_factory(object_factory):
#     starknet, object, accounts = object_factory
#     # Deploy
#     print(f'Deploying philand...')
#     philand = await starknet.deploy(source=PHILAND_FILE,
#     constructor_calldata=[
#         object.contract_address,
#         L1_ADDRESS,
#     ])
#     print(f'phi contract address is: {hex(philand.contract_address)}')
#     return starknet, philand, object, accounts

# @pytest.mark.asyncio
# async def test_create_philand(
#     philand_factory
# ):
#     starknet, philand,_, accounts = philand_factory
#     await starknet.send_message_to_l2(
#         from_address=L1_ADDRESS,
#         to_address=philand.contract_address,
#         selector="create_philand",
#         payload=[
#             *to_split_uint(ENS_NAME_INT)
#         ],
#     )
#     number_of_philand = await philand.view_number_of_philand().call()
#     assert number_of_philand.result.res == 1
#     response = await philand.view_philand(to_split_uint(ENS_NAME_INT)).call()
#     print(response.result)
#     print('Above is the newly created your philand')

# @pytest.mark.asyncio
# async def test_claim_starter_object(
#     philand_factory
# ):
#     starknet, philand, object, accounts = philand_factory
#     payload = [*to_split_uint(ENS_NAME_INT),accounts[0].contract_address]
#     await signers[0].send_transaction(
#         account=accounts[0],
#         to=philand.contract_address,
#         selector_name='claim_starter_object',
#         calldata=payload)

#     account_check = [accounts[0].contract_address,
#                 accounts[0].contract_address, accounts[0].contract_address,
#                 accounts[0].contract_address, accounts[0].contract_address]
#     token_ids = [(1, 0), (2, 0), (3, 0),(4,0),(5,0)]
#     response=await object.balance_of_batch(account_check, token_ids).call()
#     print(response.result.res)
#     assert response.result.res == [1,1,1,1,1]
#     assert len(response.result.res) == len(token_ids)


# @pytest.mark.asyncio
# async def test_write_object(
#     philand_factory
# ):
#     starknet, philand, object, accounts = philand_factory
#     token_id=1
#     payload = [2,2,2,*to_split_uint(ENS_NAME_INT),DUMMY_ADDRESS,*to_split_uint(token_id)]
#     await signers[0].send_transaction(
#         account=accounts[0],
#         to=philand.contract_address,
#         selector_name='write_object_to_landt',
#         calldata=payload)

# async def view(images):
#     # For an philand appearance:
#     # .replace('1','■ ').replace('0','. ')
#     for index, image in enumerate(images):
#         print(f"your philand:")
#         print(format(image[0:8]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[8:16]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[16:24]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[24:32]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[32:40]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[40:48]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[48:56]).replace('1', '■ ').replace('0', '. '))
#         print(format(image[56:64]).replace('1', '■ ').replace('0', '. '))

