// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CallMeChallenge {
    bool public isComplete = false;

    function callme() public {
        isComplete = true;
    }
}
