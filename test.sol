pragma solidity ^0.8.10;

contract test {
    mapping(address => uint256) balanceOf;
    struct TopBalance {
        uint256 balance;
        address addr;
    }
    TopBalance[10] public topBalances;

    function pay2() public {
        elaborateTopX(msg.sender, 10);
    }

    function elaborateTopX(address addr, uint256 currentValue) private {
        uint256 i = 0;
        /** get the index of the current max element **/
        for (i; i < topBalances.length; i++) {
            if (topBalances[i].balance < currentValue) {
                break;
            }
        }
        /** shift the array of position (getting rid of the last element) **/
        for (uint256 j = topBalances.length - 1; j > i; j--) {
            topBalances[j].balance = topBalances[j - 1].balance;
            topBalances[j].addr = topBalances[j - 1].addr;
        }
        /** update the new max element **/
        topBalances[i].balance = currentValue;
        topBalances[i].addr = addr;
    }
}
