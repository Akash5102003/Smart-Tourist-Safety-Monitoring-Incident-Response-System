from blockchain_config import contract

def test_read():
    result = contract.functions.getTourist(
        "0x0000000000000000000000000000000000000000"
    ).call()
    print(result)

test_read()
