// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract MultiSigWallet {
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private _numConfirmationsRequired;
    EnumerableSet.AddressSet private _owners;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        address[] confirmations;
    }

    Transaction[] private _transactions;

    event Deposit(address indexed sender, uint256 value);
    event SubmitTransaction(address indexed owner, uint256 indexed txIndex, address indexed to, uint256 value, bytes data);
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    modifier onlyOwner() {
        require(_owners.contains(msg.sender), "MultiSigWallet: caller is not an owner");
        _;
    }

    constructor(address[] memory owners_, uint256 numConfirmationsRequired_) {
        require(owners_.length > 0, "MultiSigWallet: owners required");
        require(numConfirmationsRequired_ > 0 && numConfirmationsRequired_ <= owners_.length, "MultiSigWallet: invalid number of confirmations");

        for (uint256 i = 0; i < owners_.length; i++) {
            address owner = owners_[i];
            require(owner != address(0), "MultiSigWallet: invalid owner");
            require(!_owners.contains(owner), "MultiSigWallet: owner not unique");
            _owners.add(owner);
        }

        _numConfirmationsRequired = numConfirmationsRequired_;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address to, uint256 value, bytes memory data) external onlyOwner {
        uint256 txIndex = _transactions.length;
        address[] memory initialConfirmations = new address[](1);
        initialConfirmations[0] = msg.sender;

        _transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: initialConfirmations
        }));

        emit SubmitTransaction(msg.sender, txIndex, to, value, data);
    }

    function confirmTransaction(uint256 txIndex) external onlyOwner {
        require(!_transactions[txIndex].executed, "MultiSigWallet: transaction already executed");
        require(!_isConfirmed(txIndex, msg.sender), "MultiSigWallet: transaction already confirmed by this owner");
        _transactions[txIndex].confirmations.push(msg.sender);
        emit ConfirmTransaction(msg.sender, txIndex);
    }

    function _isConfirmed(uint256 txIndex, address owner) internal view returns (bool) {
        Transaction storage transaction = _transactions[txIndex];
        for (uint256 i = 0; i < transaction.confirmations.length; i++) {
            if (transaction.confirmations[i] == owner) {
                return true;
            }
        }
        return false;
    }

    function executeTransaction(uint256 txIndex) external onlyOwner {
        Transaction storage transaction = _transactions[txIndex];
        require(!transaction.executed, "MultiSigWallet: transaction already executed");
        require(transaction.confirmations.length >= _numConfirmationsRequired, "MultiSigWallet: not enough confirmations");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "MultiSigWallet: transaction execution failed");
        emit ExecuteTransaction(msg.sender, txIndex);
    }

    function getOwners() external view returns (address[] memory) {
        uint256 length = _owners.length();
        address[] memory ownersArray = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            ownersArray[i] = _owners.at(i);
        }
        return ownersArray;
    }

    function numConfirmationsRequired() external view returns (uint256) {
        return _numConfirmationsRequired;
    }

    function getTransactionCount() external view returns (uint256) {
        return _transactions.length;
    }
}
