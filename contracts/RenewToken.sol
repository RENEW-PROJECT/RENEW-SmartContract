// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./MutiSignature.sol";

contract RenewToken is ERC20, ReentrancyGuard {
    mapping(address => uint256) private _lockedBalances;

    event TokensLocked(address indexed user, uint256 amount);
    event TokensUnlocked(address indexed user, uint256 amount);
    address public multiSigWallet;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 _decimals
    ) ERC20(name, symbol) {
        decimal = _decimals;
        _mint(msg.sender, initialSupply * (10**uint256(_decimals)));
    }

    uint8 private decimal;
    function decimals() public view virtual override returns (uint8) {
        return decimal;
    }
    modifier onlyMultiSigWallet() {
        require(msg.sender == multiSigWallet, "RenewToken: Only multi-signature wallet can call this function");
        _;
    }

    function lockTokens(address user, uint256 amount) external onlyMultiSigWallet{
        require(user != address(0), "RenewToken: Invalid address");
        require(amount > 0, "RenewToken: Amount must be greater than zero");
        require(amount <= balanceOf(user), "RenewToken: Insufficient balance");

        _lockedBalances[user] += amount;
        emit TokensLocked(user, amount);
    }

    function unlockTokens(address user, uint256 amount) private onlyMultiSigWallet{
        require(user != address(0), "RenewToken: Invalid address");
        require(amount > 0, "RenewToken: Amount must be greater than zero");
        require(amount <= _lockedBalances[user], "RenewToken: Insufficient locked balance");

        _lockedBalances[user] -= amount;
        emit TokensUnlocked(user, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf(msg.sender) - _lockedBalances[msg.sender] >= amount, "RenewToken: Transfer amount exceeds unlocked balance");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf(sender) - _lockedBalances[sender] >= amount, "RenewToken: Transfer amount exceeds unlocked balance");
        return super.transferFrom(sender, recipient, amount);
    }

    function batchTransfer(address[] memory recipients, uint256[] memory amounts) external nonReentrant {
        require(recipients.length == amounts.length, "RenewToken: Arrays length mismatch");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "RenewToken: Invalid recipient");
            totalAmount += amounts[i];
        }
        require(balanceOf(msg.sender) - _lockedBalances[msg.sender] >= totalAmount, "RenewToken: Total transfer amount exceeds unlocked balance");
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }
}
