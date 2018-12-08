pragma solidity ^0.4.25;

contract Withdrawable {
    mapping(address => uint) internal pendingWithdrawals;
    
    function withdraw() public {
        require(pendingWithdrawals[msg.sender] > 0);
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}