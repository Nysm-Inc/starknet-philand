from typing import Dict, Any
import json
import os
from decimal import Decimal
import logging
import pprint
from etherscan import Etherscan
from web3 import Web3
from eth_event import *
import requests
from web3 import Web3, HTTPProvider
import boto3


addr = '0x58Eb67DcA41dAC355cE0E9858bA3e8E9e867FC93'
network = "goerli"
ETHERSCAN_API_KEY = "Y64ED755T1YMYFBH32KB26T3VD4Y5D96KK"
INFURA="https://goerli.infura.io/v3/d2aaa0388c5049bdb07949044d435ee8"
# INFURA = "https://mainnet.infura.io/v3/d2aaa0388c5049bdb07949044d435ee8"


eth = Etherscan(ETHERSCAN_API_KEY, net=network)
balance = eth.get_eth_balance(address=addr)

# wei -> eth
print(Decimal(balance) / Decimal(10e17))

txs = eth.get_normal_txs_by_address(
    address=addr, startblock=0, endblock=99999999, sort='asc')

print(len(txs))

w3 = Web3()
# json_load = json.loads(open("./utils/uniswap-abi.json").read())
json_load = json.loads(open("./utils/abi.json").read())
topic_map = get_topic_map(json_load)



web3 = Web3(HTTPProvider(INFURA))
tx = web3.eth.waitForTransactionReceipt(
    '0x66bcd62c1ff60826fbe4e9ba1420f3453c2a82909c9b6d394221798534b697d5')
print("---------")
print(tx)
print("---------")
abi_endpoint = f"https://api.etherscan.io/api?module=contract&action=getabi&address={tx['to']}&apikey={ETHERSCAN_API_KEY}"
abi = json.loads(requests.get(abi_endpoint).text)
# このABIファイルが使える
print(abi)


# Create Web3 contract object
# contract = web3.eth.contract(address=tx["to"], abi=abi["result"])
# # Decode input data using Contract object's decode_function_input() method
# func_obj, func_params = contract.decode_function_input(
#     "0x5ae401dc000000000000000000000000000000000000000000000000000000006211b19a000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000000e45023b4df000000000000000000000000b4fbf271143f4fbf7b91a5ded31805e42b2208d6000000000000000000000000d87ba7a50b2e7e660f678a895e4b72e7cb4ccd9c0000000000000000000000000000000000000000000000000000000000000bb800000000000000000000000058eb67dca41dac355ce0e9858ba3e8e9e867fc930000000000000000000000000000000000000000000000000000000024d51fdc00000000000000000000000000000000000000000000000006f93cd0b4c2990c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000412210e8a00000000000000000000000000000000000000000000000000000000")
# # result = decode_logs(tx.logs, topic_map)
# # print(result)
# print(func_obj)
# print("---------")
# a=func_params["data"][0]
# print(str(a))
# # print(a.decode())
# # print(a.decode("utf-8"))
# # TODO: JSON 形式にするのを調べる
# # print(decoded_input)
# # for tx in txs:
# #     pprint.pprint(tx)

