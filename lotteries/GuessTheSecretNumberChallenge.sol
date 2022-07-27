// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GuessTheSecretNumberChallenge {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        bytes memory _n = toBytes(n);

        if (bytes32(keccak256(_n)) == answerHash) {
            payable(msg.sender).transfer(2 ether);
        }
    }

    function toBytes(uint256 x) public returns (bytes memory b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
}
