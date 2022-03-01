from starkware.starknet.compiler.compile import \
    get_selector_from_name

MAX_UINT256 = (2**128 - 1, 2**128 - 1)
MAX_LEN_FELT = 31

def str_to_felt(text):
    b_text = bytes(text, 'ascii')
    return int.from_bytes(b_text, "big")


def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()


def str_to_bytes(text):
    b_text = bytes(text, 'ascii')
    return b_text


def str_to_felt_array(text):
    # Break string into array of strings that meet felt requirements
    chunks = []
    for i in range(0, len(text), MAX_LEN_FELT):
        str_chunk = text[i:i+MAX_LEN_FELT]
        chunks.append(str_to_felt(str_chunk))
    return chunks


print(get_selector_from_name('create_philand'))
print(get_selector_from_name('claim_l1_object'))
print(get_selector_from_name('claim_l2_object'))

print(str_to_felt('zak3939.eth'))
print(str_to_bytes('zak3939.eth'))
print(felt_to_str(147948997034476692113290344))
# console.log(BigInt(web3.utils.asciiToHex('object')))
# print(felt_to_str(
#     55354291560282261680205140228934436588969903936754548205611172710617586860032))
# print(str_to_felt("object"))
# print(str_to_felt("philand"))
# print(str_to_felt("{id}"))

print(*str_to_felt_array(
    "https://dweb.link/ipfs/bafyreiffxtdf5bobkwevesevvnevvug4i4qeodvzhseknoepbafhx7yn3e/metadata.json"))
print("next")
print(*str_to_felt_array(
    "https://dweb.link/ipfs/bafyreifw4jmfjiouqtvhxvvaoxe7bbhfi5fkgzjeqt5tpvkrvszcx5n3zy/metadata.json"))
