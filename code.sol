// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureLendingProtocol {
    mapping(address => uint256) public deposits; 
    mapping(address => uint256) public debts;    
    uint256 public totalDeposits;                

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    } 
    function borrow(uint256 amount) public {
        require(amount > 0, "Borrow amount must be greater than zero");
        require(deposits[msg.sender] >= amount, "Insufficient collateral");
        require(amount <= totalDeposits, "Insufficient funds in protocol");

        debts[msg.sender] += amount;
        totalDeposits -= amount;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");

        emit Borrow(msg.sender, amount);
    }

    function repay() public payable {
        require(msg.value > 0, "Repay amount must be greater than zero");
        require(debts[msg.sender] >= msg.value, "Repay exceeds debt");

        debts[msg.sender] -= msg.value;
        totalDeposits += msg.value;

        emit Repay(msg.sender, msg.value);
    }

    function netBalance(address user) public view returns (uint256) {
        return deposits[user] > debts[user] ? deposits[user] - debts[user] : 0;
    }
}
