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


def to_split_uint(a):
    return (a & ((1 << 128) - 1), a >> 128)


print(get_selector_from_name('create_philand'))
print(get_selector_from_name('claim_l1_object'))
print(get_selector_from_name('claim_l2_object'))
print(get_selector_from_name('handle_deposit'))
print(to_split_uint(
    52647538822279922024551388030138050460193271338065356392198033900375906451456))

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



print("id:1")
print(str_to_felt_array("https://bafyreig7a6iezakkky25h7qwtxw4idn7ttgmkkqfmiaf2eezf2zpsr2dg4.ipfs.dweb.link/metadata.json"))
print("id:2")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreifhkrjl3eo3qixofehnshrxnlz6nosd3zachst7d6cr7gsn6krmxm/metadata.json"))
print("id:3")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreibsvbkw6u6ltgtgne3l5efzlnwpf65bdqonyo5mdop5gmu6jtapca/metadata.json"))
print("id:4")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreiadunyydcvk5gas2ltu2hpbllutftltjop66gq35ckmbo5o5pgcie/metadata.json"))
print("id:5")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreidimhonbyf2dmfkwsfgru7jy2n6ixyfr4bmwqjuf7vqrx6voxi4tu/metadata.json"))
print("id:6")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreids2mkzfzhl26hoshmmpc5mudmz4anti4dmskjsykgjvz2o5d3wwm/metadata.json"))
print("id:7")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreieq3yrcie5phpgbwxaig6exosznc23cxcde3by36bakequ24zwymu/metadata.json"))
print("id:8")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreifyd7b576se6cf5mzywxu4znfuqzw43lrf2irgjidhcqq4xvvrjti/metadata.json"))
print("id:9")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreiaewslbnuxj4kfqvatzjs5dpmmrswtyah7r7rxtshw5a7igjks73u/metadata.json"))
print("id:10")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreigb2ltsvhr4lgt6h2xmsyakw2nrxj3f4j6zb34n64au3t5ae4vhz4/metadata.json"))
print("id:11")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreicud4icbxdgukl7u3fjxovoildamvwlh2pf7ipldyolrx6n3sqtiu/metadata.json"))
print("id:12")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreib62zurt4enxttuydrtfpew4wti4u7bnd25dichniqdxhdipjscia/metadata.json"))
print("material:id:1")
print(str_to_felt_array("https://dweb.link/ipfs/bafyreihuydndhyqyu6x4rd2ofbpyfxeptva7tqlqdm3rlp4ub6dvgn3xry/metadata.json"))



