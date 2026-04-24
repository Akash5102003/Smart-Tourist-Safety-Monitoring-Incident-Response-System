# Simulated Blockchain Storage (acts like smart contract)
blockchain_db = {}

def register_tourist(user_address, name, id_hash):
    blockchain_db[user_address] = {
        "name": name,
        "idHash": id_hash,
        "verified": True
    }
    return True


def get_tourist(user_address):
    return blockchain_db.get(user_address, {
        "name": "",
        "idHash": "",
        "verified": False
    })
