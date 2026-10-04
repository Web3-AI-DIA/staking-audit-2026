// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleStaking
 * @notice Users stake an ERC20 token and earn rewards over time.
 * @dev This is a simplified staking contract for audit and learning purposes.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SimpleStaking {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public rewardRate;        // rewards per second per staked token
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public balances;

    uint256 public totalStaked;

    address public owner;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    constructor(address _stakingToken, address _rewardToken, uint256 _rewardRate) {
        require(_stakingToken != address(0), "staking token zero");
        require(_rewardToken != address(0), "reward token zero");
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        uint256 timeDelta = block.timestamp - lastUpdateTime;
        return rewardPerTokenStored + (timeDelta * rewardRate * 1e18) / totalStaked;
    }

    function earned(address account) public view returns (uint256) {
        uint256 userBalance = balances[account];
        uint256 delta = rewardPerToken() - userRewardPerTokenPaid[account];
        return (userBalance * delta) / 1e18 + rewards[account];
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        totalStaked += amount;
        balances[msg.sender] += amount;
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "stake transfer failed");
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(balances[msg.sender] >= amount, "insufficient staked");
        totalStaked -= amount;
        balances[msg.sender] -= amount;
        require(stakingToken.transfer(msg.sender, amount), "withdraw transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "no reward");
        rewards[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, reward), "reward transfer failed");
        emit RewardPaid(msg.sender, reward);
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner updateReward(address(0)) {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(_rewardRate);
    }

    function rescueTokens(address token, uint256 amount) external onlyOwner {
        require(token != address(stakingToken), "cannot rescue staking token");
        IERC20(token).transfer(owner, amount);
    }
}
