// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TouristID {

    struct Tourist {
        string name;
        string idHash;
        bool verified;
    }

    mapping(address => Tourist) public tourists;

    function registerTourist(
        address _user,
        string memory _name,
        string memory _idHash
    ) public {
        tourists[_user] = Tourist(_name, _idHash, true);
    }

    function getTourist(address _user)
        public
        view
        returns (string memory, string memory, bool)
    {
        Tourist memory t = tourists[_user];
        return (t.name, t.idHash, t.verified);
    }
}
