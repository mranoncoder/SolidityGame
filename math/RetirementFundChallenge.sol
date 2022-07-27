// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract RetirementFundChallenge {
    uint256 startBalance;
    address owner = msg.sender;
    address beneficiary;
    uint256 expiration = block.timestamp + 3650 days;

    constructor(address player) payable {
        require(msg.value == 1 ether);

        beneficiary = player;
        startBalance = msg.value;
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function withdraw() public {
        require(msg.sender == owner);

        if (block.timestamp < expiration) {
            // early withdrawal incurs a 10% penalty
            payable(msg.sender).transfer((address(this).balance * 9) / 10);
        } else {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function collectPenalty() public {
        require(msg.sender == beneficiary);

        uint256 withdrawn = startBalance - address(this).balance;

        // an early withdrawal occurred
        require(withdrawn > 0);

        // penalty is what's left
        payable(msg.sender).transfer(address(this).balance);
    }
}
