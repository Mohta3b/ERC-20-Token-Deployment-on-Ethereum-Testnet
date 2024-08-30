// SPDX-License-Identifier: GPL
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    // Token Properties
    string public constant token_name = "AmiraliTestToken";
    string public constant token_symbol = "ATT";
    uint8 public constant token_decimals = 18;

    // Total Supply Definition
    uint256 public constant TOTAL_SUPPLY = 1000000 * 10**(uint256(token_decimals));

    // Contract Owner
    address public owner;

    // Security Enhancements
    mapping(address => uint256) public lastMintTimestamp;
    mapping(address => bytes32) public challenges;
    
    // Global minting cooldown
    uint256 public globalLastMintTimestamp;
    uint256 public constant MINT_COOLDOWN = 1 minutes;

    // Secret key (private key used in proof generation)
    bytes32 private secretKey;

    // Events
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    constructor() ERC20(token_name, token_symbol) {
        owner = msg.sender;
        uint256 initialOwnerSupply = TOTAL_SUPPLY / 2; // Half of the total supply
        _mint(msg.sender, initialOwnerSupply); // Mint half of the total supply to the owner
        secretKey = keccak256(abi.encodePacked(block.timestamp, owner)); // Secret key initialization
        globalLastMintTimestamp = block.timestamp; // Initialize global cooldown
    }

    // Minting Function with Access Control (only owner)
    function mint(address recipient, uint256 amount) public onlyOwner globalCooldown {
        require(totalSupply() + amount <= TOTAL_SUPPLY, "Minting exceeds total supply");
        _mint(recipient, amount);
        emit Mint(recipient, amount); 
    }
    
    // Burning Function
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    // Ownership Transfer Function
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // Modifier to restrict functions to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // Global Minting Cooldown Modifier
    modifier globalCooldown() {
        require(block.timestamp >= globalLastMintTimestamp + MINT_COOLDOWN, "Global minting cooldown in effect");
        _;
        globalLastMintTimestamp = block.timestamp; // Update global cooldown timestamp
    }

    // Minting with Proof (Simple Challenge Mechanism)
    function mintWithProof(uint256 amount, bytes32 solution) public globalCooldown {
        require(_checkProof(solution), "Invalid proof provided");
        require(totalSupply() + amount <= TOTAL_SUPPLY, "Minting exceeds total supply");
        _mint(msg.sender, amount);
        lastMintTimestamp[msg.sender] = block.timestamp;
        emit Mint(msg.sender, amount);
    }

    // Challenge Generation Function
    function generateChallenge() public returns (bytes32) {
        bytes32 challenge = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        challenges[msg.sender] = challenge;
        return challenge;
    }

    // Proof Verification Function
    function _checkProof(bytes32 solution) internal view returns (bool) {
        // Verify the solution by checking if it matches the hash of the challenge + secret key
        bytes32 challenge = challenges[msg.sender];
        bytes32 correctSolution = keccak256(abi.encodePacked(challenge, secretKey));
        return (solution == correctSolution);
    }
}
