from web3 import Web3
import json

# Ganache RPC
GANACHE_URL = "http://127.0.0.1:7545"

web3 = Web3(Web3.HTTPProvider(GANACHE_URL))

# Check connection
if not web3.is_connected():
    raise Exception("Blockchain not connected")

# Contract address (PASTE YOUR ADDRESS HERE)
contract_address = web3.to_checksum_address(
    "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8"
)

# Contract ABI (PASTE ABI JSON HERE)
contract_abi = json.loads("""
[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_idHash",
				"type": "string"
			}
		],
		"name": "registerTourist",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getTourist",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "tourists",
		"outputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "idHash",
				"type": "string"
			},
			{
				"internalType": "bool",
				"name": "verified",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
""")

# Create contract object
contract = web3.eth.contract(
    address=contract_address,
    abi=contract_abi
)
