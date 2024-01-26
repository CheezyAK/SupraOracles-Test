// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSignatureWallet {
    address[] public owners;
    uint public quorum;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }
    
    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public approvals;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    modifier transactionExists(uint _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    constructor(address[] memory _owners, uint _quorum) {
        require(_owners.length > 0, "Owners required");
        require(_quorum > 0 && _quorum <= _owners.length, "Invalid quorum");

        owners = _owners;
        quorum = _quorum;
    }

    function isOwner(address _owner) public view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) {
                return true;
            }
        }
        return false;
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        Transaction memory newTransaction;
        newTransaction.to = _to;
        newTransaction.value = _value;
        newTransaction.data = _data;
        newTransaction.executed = false;

        transactions.push(newTransaction);
    }

    function approveTransaction(uint _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) {
        require(!approvals[_txIndex][msg.sender], "Already approved");

        approvals[_txIndex][msg.sender] = true;

        if (isTransactionApproved(_txIndex)) {
            executeTransaction(_txIndex);
        }
    }

    function cancelTransaction(uint _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) {
        delete transactions[_txIndex];
    }

    function isTransactionApproved(uint _txIndex) public view returns (bool) {
        uint approvalsCount = 0;

        for (uint i = 0; i < owners.length; i++) {
            if (approvals[_txIndex][owners[i]]) {
                approvalsCount++;
            }
            if (approvalsCount == quorum) {
                return true;
            }
        }

        return false;
    }

    function executeTransaction(uint _txIndex) internal {
        require(transactions[_txIndex].value <= address(this).balance, "Insufficient balance");

        (bool success, ) = transactions[_txIndex].to.call{value: transactions[_txIndex].value}(transactions[_txIndex].data);
        require(success, "Execution failed");

        transactions[_txIndex].executed = true;
    }

    receive() external payable {}
}
