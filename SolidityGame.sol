// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * Check my Social
 * Instagram: https://www.instagram.com/arab.sol/
 * Youtube: https://www.youtube.com/c/abolfazl
 * Twitter: https://twitter.com/arab_eth
 * @author Abol, SMARX
 */

import "./warmup/DeployChallenge.sol";
import "./warmup/CallMeChallenge.sol";
import "./warmup/NicknameChallenge.sol";

import "./lotteries/GuessTheNumberChallenge.sol";
import "./lotteries/GuessTheSecretNumberChallenge.sol";
import "./lotteries/GuessTheRandomNumberChallenge.sol";
import "./lotteries/GuessTheNewNumberChallenge.sol";
import "./lotteries/PredictTheFutureChallenge.sol";
import "./lotteries/PredictTheBlockHashChallenge.sol";

import "./math/TokenSaleChallenge.sol";
import "./math/TokenWhaleChallenge.sol";
import "./math/RetirementFundChallenge.sol";
import "./math/DonationChallenge.sol";
import "./math/FiftyYearsChallenge.sol";

import "./accounts/FuzzyIdentityChallenge.sol";
import "./accounts/PublicKeyChallenge.sol";
import "./accounts/AccountTakeoverChallenge.sol";

import "./miscellaneous/AssumeOwnershipChallenge.sol";
import "./miscellaneous/TokenBankChallenge.sol";

function quickSort(
    uint256[] memory arr,
    int256 left,
    int256 right
) pure {
    int256 i = left;
    int256 j = right;
    if (i == j) return;
    uint256 pivot = arr[uint256(left + (right - left) / 2)];

    while (i <= j) {
        while (arr[uint256(i)] > pivot) i++;
        while (pivot > arr[uint256(j)]) j--;
        if (i <= j) {
            (arr[uint256(i)], arr[uint256(j)]) = (
                arr[uint256(j)],
                arr[uint256(i)]
            );
            i++;
            j--;
        }
    }
    if (left < j) quickSort(arr, left, j);
    if (i < right) quickSort(arr, i, right);
}

// Relevant part of the CaptureTheEther contract.
contract SolidityGame {
    address[] players;
    mapping(address => bool) private isPlayer;
    mapping(address => bytes32) public nicknameOf; // name list of the players
    mapping(address => uint256) public scoreOf;
    mapping(address => mapping(uint256 => bool)) public chalangeStateOf;

    struct contractState {
        address addr;
        uint256 timestamp;
    }
    mapping(address => mapping(uint256 => contractState)) public contractOf;
    mapping(uint256 => uint256) public challengeReward;

    struct TopPlayers {
        uint256 score;
        address addr;
    }
    TopPlayers[10] public topPlayers;

    DeployChallenge public deployChallenge;
    CallMeChallenge public callMeChallenge;
    NicknameChallenge public nicknameChallenge;
    GuessTheNumberChallenge public guessTheNumberChallenge;
    GuessTheSecretNumberChallenge public guessTheSecretNumberChallenge;
    GuessTheRandomNumberChallenge public guessTheRandomNumberChallenge;
    GuessTheNewNumberChallenge public guessTheNewNumberChallenge;
    PredictTheFutureChallenge public predictTheFutureChallenge;
    PredictTheBlockHashChallenge public predictTheBlockHashChallenge;
    TokenSaleChallenge public tokenSaleChallenge;
    TokenWhaleChallenge public tokenWhaleChallenge;
    RetirementFundChallenge public retirementFundChallenge;
    DonationChallenge public donationChallenge;
    FiftyYearsChallenge public fiftyYearsChallenge;
    FuzzyIdentityChallenge public duzzyIdentityChallenge;
    PublicKeyChallenge public publicKeyChallenge;
    AccountTakeoverChallenge public accountTakeoverChallenge;
    AssumeOwnershipChallenge public assumeOwnershipChallenge;
    TokenBankChallenge public tokenBankChallenge;

    constructor(uint256[] memory _rewards) {
        for (uint256 i = 0; i < _rewards.length; i++) {
            challengeReward[i] = _rewards[i];
        }
    }

    function setNickname(bytes32 nickname) public {
        nicknameOf[msg.sender] = nickname;
    }

    function getPlayer()
        public
        view
        returns (
            address user,
            bytes32 nickname,
            uint256 score
        )
    {
        return (msg.sender, nicknameOf[msg.sender], scoreOf[msg.sender]);
    }

    function getChallengeState(uint256 _index)
        public
        view
        returns (address addr, uint256 timestamp)
    {
        addr = contractOf[msg.sender][_index].addr;
        timestamp = contractOf[msg.sender][_index].timestamp;
        return (addr, timestamp);
    }

    function fetchLeaderboard(uint256 _amount)
        public
        view
        returns (
            address[] memory addresses,
            bytes32[] memory nicknames,
            uint256[] memory scores
        )
    {
        address[] memory addresses = new address[](_amount);
        uint256[] memory scores = new uint256[](_amount);
        bytes32[] memory nicknames = new bytes32[](_amount);

        for (uint256 i = 0; i < _amount; i++) {
            addresses[i] = topPlayers[i].addr;
            scores[i] = topPlayers[i].score;
            nicknames[i] = nicknameOf[topPlayers[i].addr];
        }
        return (addresses, nicknames, scores);
    }

    function completeChallenge(uint256 _index) public {
        DeployChallenge userContract = DeployChallenge(
            contractOf[msg.sender][_index].addr
        );
        require(address(userContract) != address(0), "THE_CONTRACT_NOT_FOUND");
        require(userContract.isComplete(), "THE_CHALLENGE_IS_NOT_FINISHED");
        payReward(msg.sender, _index);
    }

    function payReward(address _user, uint256 _index) internal {
        if (!chalangeStateOf[_user][_index]) {
            scoreOf[_user] += challengeReward[_index];
            chalangeStateOf[_user][_index] = true;
            setTopX(msg.sender, scoreOf[msg.sender]);
        }
    }

    function setTopX(address addr, uint256 currentValue) private {
        uint256 i = 0;
        bool alreadyInAccount;

        for (i; i < topPlayers.length; i++) {
            if (topPlayers[i].addr == addr) {
                alreadyInAccount = true;
                break;
            } else if (topPlayers[i].score < currentValue) {
                break;
            }
        }

        if (!alreadyInAccount) {
            for (uint256 j = topPlayers.length - 1; j > i; j--) {
                topPlayers[j].score = topPlayers[j - 1].score;
                topPlayers[j].addr = topPlayers[j - 1].addr;
            }
        }
        topPlayers[i].score = currentValue;
        topPlayers[i].addr = addr;

        uint256[] memory oldBackup = new uint256[](10);
        for (uint256 n = 0; n < topPlayers.length; n++) {
            oldBackup[n] = topPlayers[n].score;
        }

        uint256[] memory newListSec = new uint256[](10);
        newListSec = sort(oldBackup);

        address[] memory oldAddrBackup = new address[](10);
        for (uint256 n = 0; n < topPlayers.length; n++) {
            oldAddrBackup[n] = topPlayers[n].addr;
        }

        for (uint256 t = 0; t < topPlayers.length; t++) {
            for (uint256 p = 0; p < topPlayers.length; p++) {
                if (oldBackup[t] == newListSec[p]) {
                    topPlayers[t].score = newListSec[p];
                    topPlayers[t].addr = oldAddrBackup[p];
                }
            }
        }
    }

    function startChallenge(uint256 _index) public payable {
        if (!isPlayer[msg.sender]) {
            players.push(msg.sender);
        }
        if (_index == 0) {
            DeployChallenge deployChallenge = new DeployChallenge();
            contractOf[msg.sender][_index].addr = address(deployChallenge);
        } else if (_index == 1) {
            CallMeChallenge callMeChallenge = new CallMeChallenge();
            contractOf[msg.sender][_index].addr = address(callMeChallenge);
        } else if (_index == 2) {
            NicknameChallenge nicknameChallenge = new NicknameChallenge(
                msg.sender
            );
            contractOf[msg.sender][_index].addr = address(nicknameChallenge);
        } else if (_index == 3) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            GuessTheNumberChallenge guessTheNumberChallenge = new GuessTheNumberChallenge{
                    value: msg.value
                }();
            contractOf[msg.sender][_index].addr = address(
                guessTheNumberChallenge
            );
        } else if (_index == 4) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            GuessTheSecretNumberChallenge guessTheSecretNumberChallenge = new GuessTheSecretNumberChallenge{
                    value: msg.value
                }();
            contractOf[msg.sender][_index].addr = address(
                guessTheSecretNumberChallenge
            );
        } else if (_index == 5) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            GuessTheRandomNumberChallenge guessTheRandomNumberChallenge = new GuessTheRandomNumberChallenge{
                    value: msg.value
                }();
            contractOf[msg.sender][_index].addr = address(
                guessTheRandomNumberChallenge
            );
        } else if (_index == 6) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            GuessTheNewNumberChallenge guessTheNewNumberChallenge = new GuessTheNewNumberChallenge{
                    value: msg.value
                }();
            contractOf[msg.sender][_index].addr = address(
                guessTheNewNumberChallenge
            );
        } else if (_index == 7) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            PredictTheFutureChallenge predictTheFutureChallenge = new PredictTheFutureChallenge{
                    value: msg.value
                }();
            contractOf[msg.sender][_index].addr = address(
                predictTheFutureChallenge
            );
        } else if (_index == 8) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            PredictTheBlockHashChallenge predictTheBlockHashChallenge = new PredictTheBlockHashChallenge{
                    value: msg.value
                }();
            contractOf[msg.sender][_index].addr = address(
                predictTheBlockHashChallenge
            );
        } else if (_index == 9) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            TokenSaleChallenge tokenSaleChallenge = new TokenSaleChallenge{
                value: msg.value
            }();
            contractOf[msg.sender][_index].addr = address(tokenSaleChallenge);
        } else if (_index == 10) {
            TokenWhaleChallenge tokenWhaleChallenge = new TokenWhaleChallenge(
                msg.sender
            );
            contractOf[msg.sender][_index].addr = address(tokenWhaleChallenge);
        } else if (_index == 11) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            RetirementFundChallenge retirementFundChallenge = new RetirementFundChallenge{
                    value: msg.value
                }(msg.sender);
            contractOf[msg.sender][_index].addr = address(
                retirementFundChallenge
            );
        } else if (_index == 12) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            DonationChallenge donationChallenge = new DonationChallenge{
                value: msg.value
            }();
            contractOf[msg.sender][_index].addr = address(donationChallenge);
        } else if (_index == 13) {
            require(msg.value == 1 ether, "YOU_NEED_TO_SEND_1_ETH");
            FiftyYearsChallenge fiftyYearsChallenge = new FiftyYearsChallenge{
                value: msg.value
            }(msg.sender);
            contractOf[msg.sender][_index].addr = address(fiftyYearsChallenge);
        } else if (_index == 14) {
            FuzzyIdentityChallenge fuzzyIdentityChallenge = new FuzzyIdentityChallenge();
            contractOf[msg.sender][_index].addr = address(
                fuzzyIdentityChallenge
            );
        } else if (_index == 15) {
            PublicKeyChallenge publicKeyChallenge = new PublicKeyChallenge();
            contractOf[msg.sender][_index].addr = address(publicKeyChallenge);
        } else if (_index == 16) {
            AccountTakeoverChallenge accountTakeoverChallenge = new AccountTakeoverChallenge();
            contractOf[msg.sender][_index].addr = address(
                accountTakeoverChallenge
            );
        } else if (_index == 17) {
            AssumeOwnershipChallenge assumeOwnershipChallenge = new AssumeOwnershipChallenge();
            contractOf[msg.sender][_index].addr = address(
                assumeOwnershipChallenge
            );
        } else if (_index == 18) {
            TokenBankChallenge tokenBankChallenge = new TokenBankChallenge(
                msg.sender
            );
            contractOf[msg.sender][_index].addr = address(tokenBankChallenge);
        }

        contractOf[msg.sender][_index].timestamp = block.timestamp;
    }

    function sort(uint256[] memory data)
        public
        pure
        returns (uint256[] memory)
    {
        quickSort(data, int256(0), int256(data.length - 1));
        return data;
    }
}
