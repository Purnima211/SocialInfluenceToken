// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Tokenized Social Influence (no imports, no constructor)
/// @notice Minimal ERC-20-like token with minting by trusted verifiers based on engagement score.
/// Deployer must call `activate()` once to become owner (no constructor used).
contract SocialInfluenceToken {
    // --- ERC20 storage ---
    string public name = "SocialInfluenceToken";
    string public symbol = "SIT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // --- Admin / roles (no constructor) ---
    address public owner;                    // set by activate()
    bool private activated;
    mapping(address => bool) public isVerifier;

    // token mint multiplier (tokens per engagement unit). Adjustable by owner.
    uint256 public engagementMultiplier = 1 ether; // 1 engagement unit -> 1 token (with decimals)

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);
    event Activated(address indexed owner);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);
    event TokensIssued(address indexed verifier, address indexed recipient, uint256 engagementScore, uint256 tokensMinted);
    event EngagementMultiplierUpdated(uint256 newMultiplier);

    // --- --- --- 
    // Activation (replaces constructor): must be called once by deployer to set owner
    function activate() external {
        require(!activated, "Already activated");
        // set the caller as owner
        owner = msg.sender;
        activated = true;
        emit Activated(owner);
    }

    // --- Modifiers ---
    modifier onlyOwner() {
        require(activated && msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyVerifier() {
        require(isVerifier[msg.sender], "Only verifier");
        _;
    }

    // --- Owner functions ---
    function addVerifier(address verifier) external onlyOwner {
        require(verifier != address(0), "zero address");
        isVerifier[verifier] = true;
        emit VerifierAdded(verifier);
    }

    function removeVerifier(address verifier) external onlyOwner {
        require(isVerifier[verifier], "not a verifier");
        isVerifier[verifier] = false;
        emit VerifierRemoved(verifier);
    }

    /// @notice Update how many token-wei are minted per unit of engagement. E.g. set to 1e18 for 1 token per score unit.
    function setEngagementMultiplier(uint256 newMultiplier) external onlyOwner {
        require(newMultiplier > 0, "multiplier>0");
        engagementMultiplier = newMultiplier;
        emit EngagementMultiplierUpdated(newMultiplier);
    }

    // --- Token issuance by verifiers ---
    /// @notice Issue tokens to a recipient based on engagementScore (integer). Only callable by trusted verifier.
    /// @param recipient address to receive tokens
    /// @param engagementScore raw engagement units (e.g., likes + weighted shares)
    function issueTokens(address recipient, uint256 engagementScore) external onlyVerifier returns (uint256) {
        require(recipient != address(0), "zero recipient");
        require(engagementScore > 0, "score>0");

        // Compute tokens to mint: engagementScore * engagementMultiplier
        uint256 tokens = engagementScore * engagementMultiplier;

        _mint(recipient, tokens);
        emit TokensIssued(msg.sender, recipient, engagementScore, tokens);
        return tokens;
    }

    // --- ERC20 core implementation ---
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= value, "allowance exceeded");
        // update allowance
        allowance[from][msg.sender] = allowed - value;
        _transfer(from, to, value);
        return true;
    }

    // --- Internal token helpers ---
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "zero to");
        uint256 bal = balanceOf[from];
        require(bal >= value, "insufficient balance");
        balanceOf[from] = bal - value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function _approve(address owner_, address spender, uint256 value) internal {
        require(spender != address(0), "zero spender");
        allowance[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "zero to");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // --- Utility / admin withdrawal if needed ---
    // Owner can recover accidental ETH sent to contract
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Accept ETH
    receive() external payable {}
}

