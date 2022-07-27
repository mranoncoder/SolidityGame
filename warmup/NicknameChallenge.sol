// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../SolidityGame.sol";

// قرارداد این چلنج
// نیازی نیست که شما کاری کنید این قرارداد فقط چک میکنه که شما اسمتون رو ثبت کردید
contract NicknameChallenge {
    SolidityGame game = SolidityGame(msg.sender);
    address player;

    // آدرس شما به عنوان یک پارامتر سازنده ارسال می شود.
    constructor(address _player) {
        player = _player;
    }

    // بررسی برای اینکه بازی کن خالی نباشه
    function isComplete() public view returns (bool) {
        return game.nicknameOf(player)[0] != 0;
    }
}
