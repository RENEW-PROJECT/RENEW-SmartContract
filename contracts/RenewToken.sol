pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RenewToken is ERC20, Ownable, ReentrancyGuard {
    mapping(address => uint256) private _lockedBalances;

    event TokensLocked(address indexed user, uint256 amount);
    event TokensUnlocked(address indexed user, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimal,
        address _owner
    ) ERC20(name, symbol) Ownable(_owner) {
        _decimal = decimal;
        _mint(_owner, initialSupply * (10**decimal));
    }
    uint8 _decimal;
    function decimals() public override view virtual returns (uint8) {return _decimal;}

    function lockTokens(address user, uint256 amount) external onlyOwner {
        require(user != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= balanceOf(user), "Insufficient balance");

        _lockedBalances[user] += amount;
        emit TokensLocked(user, amount);
    }

    function unlockTokens(address user, uint256 amount) external onlyOwner {
        require(user != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= _lockedBalances[user], "Insufficient locked balance");

        _lockedBalances[user] -= amount;
        emit TokensUnlocked(user, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf(msg.sender) - _lockedBalances[msg.sender] >= amount, "Transfer amount exceeds unlocked balance");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf(sender) - _lockedBalances[sender] >= amount, "Transfer amount exceeds unlocked balance");
        return super.transferFrom(sender, recipient, amount);
    }

    function batchTransfer(address[] memory recipients, uint256[] memory amounts) external nonReentrant {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            totalAmount += amounts[i];
        }
        require(balanceOf(msg.sender) - _lockedBalances[msg.sender] >= totalAmount, "Total transfer amount exceeds unlocked balance");
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }
}
