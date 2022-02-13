import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import Signer, uint, str_to_felt, MAX_UINT256, assert_revert
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.definitions.error_codes import StarknetErrorCode

signer = Signer(123456789987654321)
ZERO_ADDRESS = 0
# bools (for readability)
false = 0
true = 1
not_bool = 2

# random user address
user = 123
# random token IDs
tokens = [(5042, 0), (7921, 1), (0, 13), MAX_UINT256, (234, 345)]
nonexistent_token = (111, 222)

# random data (mimicking bytes in Solidity)
data = [0x42, 0x89, 0x55]

# random URIs
sample_uri = [
    str_to_felt('mock://mytoken.v1'),
    str_to_felt('mock://mytoken.v2')
]

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def erc721_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[signer.public_key]
    )

    other = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[signer.public_key]
    )

    erc721 = await starknet.deploy(
        "contracts/l2/Object.cairo",
        constructor_calldata=[
            str_to_felt("Non Fungible Token"),  # name
            str_to_felt("NFT"),                 # ticker
            account.contract_address            # owner
        ]
    )

    # mint tokens to account
    for token in tokens:
        print(*token)
        await signer.send_transaction(
            account, erc721.contract_address, 'mint', [
                account.contract_address, *token]
        )

    return starknet, erc721, account, other

#
# supportsInterface
#


@pytest.mark.asyncio
async def test_supportsInterface(erc721_factory):
    _, erc721, _, _ = erc721_factory

    enum_interface_id = 0x780e9d63

    execution_info = await erc721.supportsInterface(enum_interface_id).call()
    assert execution_info.result == (1,)

#
# totalSupply
#


@pytest.mark.asyncio
async def test_totalSupply(erc721_factory):
    _, erc721, _, _ = erc721_factory

    execution_info = await erc721.totalSupply().call()
    assert execution_info.result == (uint(5),)


#
# tokenOfOwnerByIndex
#


@pytest.mark.asyncio
async def test_tokenOfOwnerByIndex(erc721_factory):
    _, erc721, account, _ = erc721_factory

    # check index
    for i, t in zip(range(0, 5), range(0, 5)):
        execution_info = await erc721.tokenOfOwnerByIndex(account.contract_address, uint(i)).call()
        assert execution_info.result == (tokens[t],)


@pytest.mark.asyncio
async def test_tokenOfOwnerByIndex_greater_than_supply(erc721_factory):
    _, erc721, account, _ = erc721_factory

    await assert_revert(
        erc721.tokenOfOwnerByIndex(account.contract_address, uint(5)).call()
    )


@pytest.mark.asyncio
async def test_tokenOfOwnerByIndex_owner_with_no_tokens(erc721_factory):
    _, erc721, _, _ = erc721_factory

    await assert_revert(
        erc721.tokenOfOwnerByIndex(user, uint(1)).call()
    )


@pytest.mark.asyncio
async def test_tokenOfOwnerByIndex_transfer_all_tokens(erc721_factory):
    _, erc721, account, other = erc721_factory

    # transfer all tokens
    for token in tokens:
        await signer.send_transaction(
            account, erc721.contract_address, 'transferFrom', [
                account.contract_address,
                other.contract_address,
                *token
            ]
        )

    execution_info = await erc721.balanceOf(other.contract_address).call()
    assert execution_info.result == (uint(5),)

    for i, t in zip(range(0, 5), range(0, 5)):
        execution_info = await erc721.tokenOfOwnerByIndex(other.contract_address, uint(i)).call()
        assert execution_info.result == (tokens[t],)

    execution_info = await erc721.balanceOf(account.contract_address).call()
    assert execution_info.result == (uint(0),)

    # check that queries to old owner's token ownership reverts since index is less
    # than the target's balance
    await assert_revert(erc721.tokenOfOwnerByIndex(
        account.contract_address, uint(0)).call()
    )

#
# tokenByIndex
#


@pytest.mark.asyncio
async def test_tokenByIndex(erc721_factory):
    _, erc721, _, _ = erc721_factory

    for i, t in zip(range(0, 5), range(0, 5)):
        execution_info = await erc721.tokenByIndex(uint(i)).call()
        assert execution_info.result == (tokens[t],)


@pytest.mark.asyncio
async def test_tokenByIndex_greater_than_supply(erc721_factory):
    _, erc721, _, _ = erc721_factory

    await assert_revert(
        erc721.tokenByIndex(uint(5)).call()
    )


@pytest.mark.asyncio
async def test_tokenByIndex_burn_last_token(erc721_factory):
    _, erc721, account, other = erc721_factory

    # burn last token
    await signer.send_transaction(
        other, erc721.contract_address, 'burn', [
            *tokens[4]]
    )

    execution_info = await erc721.totalSupply().call()
    assert execution_info.result == (uint(4),)

    for i, t in zip(range(0, 4), range(0, 4)):
        execution_info = await erc721.tokenByIndex(uint(i)).call()
        assert execution_info.result == (tokens[t],)

    await assert_revert(
        erc721.tokenByIndex(uint(4)).call()
    )


@pytest.mark.asyncio
async def test_tokenByIndex_burn_first_token(erc721_factory):
    _, erc721, _, other = erc721_factory

    # burn first token
    await signer.send_transaction(
        other, erc721.contract_address, 'burn', [
            *tokens[0]]
    )

    # the first token should be burnt and the fourth token should be swapped
    # to the first token's index
    new_token_order = [tokens[3], tokens[1], tokens[2]]
    for i, t in zip(range(0, 3), range(0, 3)):
        execution_info = await erc721.tokenByIndex(uint(i)).call()
        assert execution_info.result == (new_token_order[t],)


@pytest.mark.asyncio
async def test_tokenByIndex_burn_and_mint(erc721_factory):
    _, erc721, account, other = erc721_factory

    new_token_order = [tokens[3], tokens[1], tokens[2]]
    for token in new_token_order:
        await signer.send_transaction(
            other, erc721.contract_address, 'burn', [
                *token]
        )

    execution_info = await erc721.totalSupply().call()
    assert execution_info.result == (uint(0),)

    await assert_revert(
        erc721.tokenByIndex(uint(0)).call()
    )

    # mint new tokens
    for token in tokens:
        await signer.send_transaction(
            account, erc721.contract_address, 'mint', [
                account.contract_address, *token]
        )

    for i, t in zip(range(0, 5), range(0, 5)):
        execution_info = await erc721.tokenByIndex(uint(i)).call()
        assert execution_info.result == (tokens[t],)


@pytest.mark.asyncio
async def test_safeTransferFrom(erc721_factory):
    _, erc721, account, erc721_holder = erc721_factory

    await signer.send_transaction(
        account, erc721.contract_address, 'safeTransferFrom', [
            account.contract_address,
            erc721_holder.contract_address,
            *tokens[0],
            len(data),
            *data
        ]
    )

    # check balance
    execution_info = await erc721.balanceOf(erc721_holder.contract_address).call()
    assert execution_info.result == (uint(1),)

    # check owner
    execution_info = await erc721.ownerOf(tokens[0]).call()
    assert execution_info.result == (erc721_holder.contract_address,)

@pytest.mark.asyncio
async def test_tokenURI(erc721_factory):
    _, erc721, account, _ = erc721_factory

    # should be zero when tokenURI is not set
    execution_info = await erc721.tokenURI(tokens[0]).call()
    assert execution_info.result == (0,)

    # setTokenURI for first_token_id
    await signer.send_transaction(
        account, erc721.contract_address, 'setTokenURI', [
            *tokens[0],
            sample_uri[0]
        ]
    )

    execution_info = await erc721.tokenURI(tokens[0]).call()
    assert execution_info.result == (sample_uri[0],)

    # setTokenURI for second_token_id
    await signer.send_transaction(
        account, erc721.contract_address, 'setTokenURI', [
            *tokens[1],
            sample_uri[1]
        ]
    )

    execution_info = await erc721.tokenURI(tokens[1]).call()
    assert execution_info.result == (sample_uri[1],)


@pytest.mark.asyncio
async def test_tokenURI_should_revert_for_nonexistent_token(erc721_factory):
    _, erc721, _, _ = erc721_factory

    # should revert for nonexistent token
    await assert_revert(erc721.tokenURI(nonexistent_token).call())


@pytest.mark.asyncio
async def test_setTokenURI_from_not_owner(erc721_factory):
    starknet, erc721, _, _ = erc721_factory
    not_owner = await starknet.deploy(
        "contracts/l2/Account.cairo",
        constructor_calldata=[signer.public_key]
    )

    await assert_revert(
        signer.send_transaction(
            not_owner, erc721.contract_address, 'setTokenURI', [
                *tokens[1],
                sample_uri[1]
            ]
        )
    )
