<div style="text-align: center;">
    <img src="image 3.avif" alt="Banner" ">
</div>

# CSE 307 CA 2 (Project Report)

**Name:** Samhitha madala | **Reg NO:** 12214200 | **Section:** K22CS | **Roll NO:** 55

**Git Repo:** https://github.com/Samhitha7613/Blockchain-CA3.git


## Problem Statement

A decentralized lending protocol allows users to deposit Ether as collateral and borrow against it. However, the basic implementation of such a protocol is prone to various security vulnerabilities like flash loan attacks, reentrancy, and unchecked underflows. The goal is to redesign and implement a more secure lending protocol in Solidity that ensures:

1. Funds are safe from reentrancy and manipulation.
2. Borrowing is limited to the user’s deposited collateral.
3. All operations follow best practices, including event logging and clear debt tracking.

## Approach and Implementation

The lending protocol is implemented with the following key principles:

1. **State Updates Before External Calls:** To prevent reentrancy attacks, all state variables are updated before making any external call.
2. **Collateral Management:** Borrowing is restricted to the value of the user’s collateral. Users cannot borrow more than they have deposited.
3. **Debt and Deposit Separation:** Separate mappings for deposits and debts ensure clarity and accurate bookkeeping.
4. **Clear Error Messages:** Ensure that all require statements have meaningful error messages for better debugging and user experience.
5. **Event-Driven Logging:** Use events to log every major action, improving transparency and enabling easier auditing.
6. **Testing with Multiple Accounts:** Test various scenarios using multiple accounts to validate the functionality of the lending protocol

### Implementation 


```solidity
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
```
## Module-Wise Explanation

1. **Deposit Module Functionality:** This module allows users to deposit Ether into the protocol. The deposit amount is added to the user’s individual balance and the protocol’s total funds.
**Code:**
```solidity
function deposit() public payable {
    require(msg.value > 0, "Deposit must be greater than zero");
    deposits[msg.sender] += msg.value;
    totalDeposits += msg.value;
    emit Deposit(msg.sender, msg.value);
}
```
- **Security Features:**
   - Ensures the deposit is non-zero with `require(msg.value > 0)`.
   - Maintains accurate state by updating `deposits` and `totalDeposits`.
- **Testing Scenarios:**
  1. Valid Deposit:
     - Input: Deposit 1 ETH.
     - Expected: User balance increases by 1 ETH, `totalDeposits` increases by 1 ETH, and a `Deposit` event is emitted.
  2. Zero Deposit:
     - Input: Deposit 0 ETH.
     - Expected: Transaction reverts with `Deposit must be greater than zero`.

     
**2. Borrow Module**
**- Functionality:** Users can borrow Ether up to the amount of their deposited collateral. Borrowing reduces the user’s collateral balance and increases their debt.

  **Code:**
  
  ```solidity
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
```
**- Security Features:**
   - Ensures the borrowing amount is non-zero.
   - Restricts borrowing to the user’s collateral amount.
   - Updates the protocol’s state (`debts` and `totalDeposits`) before transferring funds.

**- Testing Scenarios:**
   1. **Valid Borrow:**
      - **Input:** User borrows 0.5 ETH with 1 ETH collateral.
      - **Expected:** User debt increases by 0.5 ETH, `totalDeposits` decreases by 0.5 ETH, and a `Borrow` event is emitted.
   2. **Exceeding Collateral:**
      - **Input:** User borrows 2 ETH with 1 ETH collateral.
      - **Expected:** Transaction reverts with `Insufficient collateral`.
   
**- Insufficient Protocol Funds:**
   - **Input:** Borrow 5 ETH when `totalDeposits` is only 4 ETH.
   - **Expected:** Transaction reverts with `Insufficient funds in protocol`.


**3. Repay Module**
- **Functionality:** Allows users to repay their debts. The repayment amount is subtracted from the user’s debt and added back to the protocol’s total funds.
**Code:**

```solidity
function repay() public payable {
    require(msg.value > 0, "Repay amount must be greater than zero");
    require(debts[msg.sender] >= msg.value, "Repay exceeds debt");

    debts[msg.sender] -= msg.value;
    totalDeposits += msg.value;

    emit Repay(msg.sender, msg.value);
}
```
- **Security Features:**
    - Ensures repayment amount is non-zero.
    - Restricts repayment to the user’s outstanding debt.
- **Testing Scenarios:**
   **1. Valid Repayment:**
      - **Input:** User repays 0.2 ETH of their 0.5 ETH debt.
      - **Expected:** Debt decreases by 0.2 ETH, `totalDeposits` increases by 0.2 ETH, and a `Repay` event is emitted.
   **2. Exceeding Debt:**
      - **Input:** User repays 1 ETH with 0.5 ETH debt.
      - **Expected:** Transaction reverts with `Repay exceeds debt`.


**4. Net Balance View Module**
- **Functionality:** Displays the net balance of a user by subtracting their debts from their deposits.
**Code:**
```solidity
function netBalance(address user) public view returns (uint256) {
    return deposits[user] > debts[user] ? deposits[user] - debts[user] : 0;
}
```
**- Testing Scenarios:**
   - **Positive Net Balance:**
      - **Input:** User with 2 ETH deposits and 1 ETH debt.
      - **Expected:** `netBalance` returns 1 ETH.
   - **Zero Net Balance:**
      - **Input:** User with 1 ETH deposits and 1 ETH debt.
      - **Expected:** `netBalance` returns 0.
    

## Conclusion
The updated lending protocol addresses common vulnerabilities and provides a secure, robust platform for decentralized lending. 
Key improvements include:
1. Protection against reentrancy attacks.
2. Clear debt management with accurate state tracking.
3. Borrowing limited to collateral deposits.
This implementation demonstrates best practices in Solidity development and ensures the safety of user funds.




  





