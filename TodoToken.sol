// SPDX-License-Identifier: GPL
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    // TODO: change these variables as you wish
    // Token Properties
    string public constant token_name = "AmiraliTestToken";
    string public constant token_symbol = "ATT";
    uint8 public constant token_decimals = 18;

    // Total Supply Definition
    uint256 public constant TOTAL_SUPPLY = 1000000 * 10**(uint256(token_decimals));

    // Contract Owner
    address public owner;

    // Events
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    constructor() ERC20(token_name, token_symbol) {
        owner = msg.sender;
        // TODO: this is the part where you choose how to distribute the tokens
        
    }

    // TODO: what's wrong with this mint function? Fix it!
    // Minting Function
    function mint(address recipient, uint256 amount) public {
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

    // Minting with Proof (Simple Challenge Mechanism)
    function mintWithProof(uint256 amount, bytes32 solution) public {
        require(_checkProof(solution), "Invalid proof provided");
        require(totalSupply() + amount <= TOTAL_SUPPLY, "Minting exceeds total supply");
        _mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
    }

    // Proof Verification Function
    function _checkProof(bytes32 solution) internal view returns (bool) {
        // TODO: introduce a mechanism for verifying the proof
    }

    // TODO: how to make this token better in practice?
}
