from starkware.starknet.compiler.compile import \
    get_selector_from_name


def str_to_felt(text):
    b_text = bytes(text, 'ascii')
    return int.from_bytes(b_text, "big")


def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()


def str_to_bytes(text):
    b_text = bytes(text, 'ascii')
    return b_text
    
print(get_selector_from_name('create_grid'))
print(get_selector_from_name('claim_l1_object'))
print(get_selector_from_name('claim_l2_object'))
print(str_to_felt('zak3939.eth'))
print(str_to_bytes('zak3939.eth'))
print(felt_to_str(147948997034476692113290344))
# console.log(BigInt(web3.utils.asciiToHex('object')))

print(str_to_felt("object"))
print(str_to_felt("philand"))
print(str_to_felt("{id}"))
