pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./SafeMath.sol";


contract RenewTokSwapPoint is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => bool) public whitelist;
    mapping(uint256=>bool) convert;
    IERC20 public token;
    uint256 public ratio;
    uint256 public minConvert;

    struct Fee{
        uint256 fee;
        uint256 ratio;
    }
    Fee public systemFee;

    event UserWhiteListed(address indexed user);
    event UserWhitelistRemove(address indexed user);
    event RedeemPoint(uint256 requestId, address user, uint256 point, uint256 amount, address token);
    event RatioSet(uint256 ratio);
    event MinConvertSet(uint256 minConvert);

    constructor(address _token, uint256 _ratio, address _owner) Ownable(_owner) {
        token = IERC20(_token);
        ratio = _ratio;
        systemFee.fee = 15;
        systemFee.ratio = 1000;
        minConvert = 100;
    }

    modifier onlyOwnerOrWhiteList() {
        require(msg.sender == owner() || whitelist[msg.sender], "Invalid caller");
        _;
    }

    function setSystemFee(uint256 _fee, uint256 _ratio) external onlyOwner {
        require(_fee > 0 && _ratio > 0, "Invalid value");
        systemFee.fee = _fee;
        systemFee.ratio = _ratio;
    }

    function setWhiteList(address _user) external onlyOwner {
        require(_user != address(0), "Invalid user");
        require(!whitelist[_user], "User already in whitelist");
        whitelist[_user] = true;
        emit UserWhiteListed(_user);
    }
    function setMinConvert(uint256 _minConvert) external onlyOwner {
        require(_minConvert > 0, "Invalid number of min convert");
        minConvert = _minConvert;
        emit MinConvertSet(_minConvert);
    }

    function removeWhiteList(address _user) external onlyOwner {
        require(whitelist[_user], "User not in whitelist");
        whitelist[_user] = false;
        emit UserWhitelistRemove(_user);
    }

    function redeemPoint(address _user, uint256 _point, uint256 _id) external onlyOwnerOrWhiteList nonReentrant {
        require(address(token) != address(0), "Token is not set");
        require(_point >= 100, "Invalid number of points");
        require(!convert[_id], "Request already converted");
        uint256 received = convertPoint(_point);
        require(token.allowance(msg.sender, address(this)) >= received, "Insufficient allowance");
        token.transferFrom(msg.sender,_user, received);
        convert[_id] = true;
        emit RedeemPoint(_id, _user, _point, received, address(token));
    }

    function convertPoint(uint256 _point) public view returns (uint256) {
        require(ratio != 0, "Ratio is not set");
        uint256 total = _point.mul(ratio);
        uint256 fee = total.mul(systemFee.fee).div(systemFee.ratio);
        uint256 received = total.sub(fee);
        return received;
    }

    function configRatio(uint256 _ratio) external onlyOwner {
        require(_ratio > 0, "Invalid ratio value");
        ratio = _ratio;
        emit RatioSet(_ratio);
    }

    function configToken(address _token) external onlyOwner {
        require(_token != address(token), "Token is existed!");
        require(_token != address(0), "Invalid token");
        token = IERC20(_token);
    }
}