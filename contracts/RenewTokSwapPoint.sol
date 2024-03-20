pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./SafeMath.sol";


contract RenewTokSwapPoint is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => bool) private whitelist;
    mapping(uint256=>bool) convert;
    IERC20 public token;
    uint256 public convertRatio;
    struct LimitConvert{
        uint256 minConvert;
        uint256 maxConvert;
    }

    struct Fee{
        uint256 fee;
        uint256 ratio;
    }
    Fee public systemFee;
    LimitConvert public limitConvert;

    event UserWhiteListed(address indexed user);
    event UserWhitelistRemoved(address indexed user);
    event RedeemPoint(uint256 requestId, address user, uint256 point, uint256 amount, address token);
    event RatioSet(uint256 ratio);
    event MinConvertSet(uint256 minConvert);
    event MaxConvertSet(uint256 maxConvert);
    event SystemFeeUpdated(uint256 fee);
    event ConvertTokenUpdated(address token);

    constructor(address _token, uint256 _ratio, address _owner) Ownable(_owner) {
        token = IERC20(_token);
        convertRatio = _ratio;
        systemFee.fee = 15;
        systemFee.ratio = 1000;
        limitConvert.minConvert = 100;
        limitConvert.maxConvert = 1000000;
    }

    modifier onlyOwnerOrWhiteList() {
        require(msg.sender == owner() || whitelist[msg.sender], "Invalid caller");
        _;
    }

    function setSystemFee(uint256 _fee) external onlyOwner {
        require(_fee >= 0, "Invalid value");
        require(_fee <= 99999, "Maximum value is 99,999%");
        systemFee.fee = _fee;
        emit SystemFeeUpdated(_fee);
    }

    function whitelist(address _user, bool _isWhiteList) external onlyOwner {
        require(_user != address(0), "Invalid user");
        if (_isWhiteList == true) {
            require(!whitelist[_user], "User already in whitelist");
            whitelist[_user] = true;
            emit UserWhiteListed(_user);
        }else {
            require(whitelist[_user], "User not in whitelist");
            whitelist[_user] = false;
            emit UserWhitelistRemoved(_user);
        }
    }

    function setMinConvert(uint256 _minConvert) external onlyOwner {
        require(_minConvert > 0 && _minConvert <= limitConvert.maxConvert, "Invalid number of min convert");
        limitConvert.minConvert = _minConvert;
        emit MinConvertSet(_minConvert);
    }

    function setMaxConvert(uint256 _maxConvert) external onlyOwner {
        require(_maxConvert > 0 && _maxConvert >= limitConvert.minConvert, "Invalid number of max convert");
        limitConvert.maxConvert = _maxConvert;
        emit MaxConvertSet(_maxConvert);
    }


    function redeemPoint(address _user, uint256 _point, uint256 _id) external onlyOwnerOrWhiteList nonReentrant {
        require(address(token) != address(0), "Token is not set");
        require(_point >= limitConvert.minConvert && _point <= limitConvert.maxConvert, "Invalid number of points");
        require(!convert[_id], "Request already converted");
        uint256 received = convertPoint(_point);
        require(token.allowance(msg.sender, address(this)) >= received, "Insufficient allowance");
        token.transferFrom(msg.sender,_user, received);
        convert[_id] = true;
        emit RedeemPoint(_id, _user, _point, received, address(token));
    }

    function convertPoint(uint256 _point) public view returns (uint256) {
        require(convertRatio != 0, "Ratio is not set");
        uint256 total = _point.mul(convertRatio);
        uint256 fee = total.mul(systemFee.fee).div(systemFee.ratio);
        uint256 received = total.sub(fee);
        return received;
    }

    function configRatio(uint256 _ratio) external onlyOwner {
        require(_ratio > 0, "Invalid ratio value");
        convertRatio = _ratio;
        emit RatioSet(_ratio);
    }

    function configToken(address _token) external onlyOwner {
        require(_token != address(token), "Token is existed!");
        require(_token != address(0), "Invalid token");
        token = IERC20(_token);
        emit ConvertTokenUpdated(_token);
    }
}
