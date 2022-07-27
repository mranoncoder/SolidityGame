// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

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

contract QuickSort {
    mapping(address => uint256) balanceOf;
    struct TopBalance {
        uint256 balance;
        address addr;
    }
    TopBalance[10] public topBalances;

    function pay2(uint256 _amount) public {
        elaborateTopX(msg.sender, _amount);
    }

    struct NewBlance {
        uint256 balance;
        address addr;
    }

    function elaborateTopX(address addr, uint256 currentValue) private {
        uint256 i = 0;
        bool alreadyInAccount;
        /** get the index of the current max element **/
        for (i; i < topBalances.length; i++) {
            if (topBalances[i].addr == addr) {
                alreadyInAccount = true;
                break;
            } else if (topBalances[i].balance < currentValue) {
                break;
            }
        }

        if (!alreadyInAccount) {
            /** shift the array of position (getting rid of the last element) **/
            for (uint256 j = topBalances.length - 1; j > i; j--) {
                topBalances[j].balance = topBalances[j - 1].balance;
                topBalances[j].addr = topBalances[j - 1].addr;
            }
        }
        /** update the new max element **/
        topBalances[i].balance = currentValue;
        topBalances[i].addr = addr;

        uint256[] memory oldBackup = new uint256[](10);
        for (uint256 n = 0; n < topBalances.length; n++) {
            oldBackup[n] = topBalances[n].balance;
        }

        uint256[] memory newListSec = new uint256[](10);
        newListSec = sort(oldBackup);

        address[] memory oldAddrBackup = new address[](10);
        for (uint256 n = 0; n < topBalances.length; n++) {
            oldAddrBackup[n] = topBalances[n].addr;
        }

        for (uint256 t = 0; t < topBalances.length; t++) {
            for (uint256 p = 0; p < topBalances.length; p++) {
                if (oldBackup[t] == newListSec[p]) {
                    topBalances[t].balance = newListSec[p];
                    topBalances[t].addr = oldAddrBackup[p];
                }
            }
        }
    }

    function test(uint256[] memory data)
        public
        pure
        returns (uint256[] memory)
    {
        quickSort(data, int256(0), int256(data.length - 1));
        return data;
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
