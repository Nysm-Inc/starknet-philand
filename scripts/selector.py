from starkware.starknet.compiler.compile import \
    get_selector_from_name


def str_to_felt(text):
    b_text = bytes(text, 'ascii')
    return int.from_bytes(b_text, "big")


def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()

print(get_selector_from_name('create_grid'))
print(str_to_felt('zak3939.eth'))

