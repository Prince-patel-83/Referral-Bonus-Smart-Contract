// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ReferralBonus is ERC20 {
    // Structure to store user details
    struct User {
        bool isRegistered;
        address referrer;
        uint256 referralCount;
        uint256 bonusBalance;
    }

    // Mapping to store users
    mapping(address => User) public users;

    // Constants for rewards
    uint256 public constant REFERRER_BONUS = 50 * (10 ** 18); // 50 tokens
    uint256 public constant WELCOME_BONUS = 25 * (10 ** 18);  // 25 tokens

    // Owner of the contract
    address public owner;

    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Events
    event UserRegistered(address indexed user, address indexed referrer);
    event BonusAwarded(address indexed user, uint256 amount);
    event TokensMinted(address indexed recipient, uint256 amount);

    // Constructor to initialize the ERC-20 token
    constructor() ERC20("ReferralToken", "RFT") {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * (10 ** 18)); // Mint initial supply for the owner
    }

    // Function to register a new user
    function registerUser(address referrer) external {
        require(!users[msg.sender].isRegistered, "User is already registered");
        require(msg.sender != referrer, "You cannot refer yourself");

        // Register the user
        users[msg.sender] = User({
            isRegistered: true,
            referrer: referrer,
            referralCount: 0,
            bonusBalance: 0
        });

        // Award welcome bonus to the new user
        _mint(msg.sender, WELCOME_BONUS);
        emit BonusAwarded(msg.sender, WELCOME_BONUS);

        // If referrer exists, update their details and award bonus
        if (referrer != address(0) && users[referrer].isRegistered) {
            users[referrer].referralCount++;
            _mint(referrer, REFERRER_BONUS);
            emit BonusAwarded(referrer, REFERRER_BONUS);
        }

        emit UserRegistered(msg.sender, referrer);
    }

    // Function to check user details
    function getUserDetails(address user) external view returns (
        bool isRegistered,
        address referrer,
        uint256 referralCount,
        uint256 bonusBalance
    ) {
        User memory userDetails = users[user];
        return (
            userDetails.isRegistered,
            userDetails.referrer,
            userDetails.referralCount,
            balanceOf(user)
        );
    }

    // Function to mint additional tokens (onlyOwner)
    function mintTokens(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
        emit TokensMinted(recipient, amount);
    }
}
