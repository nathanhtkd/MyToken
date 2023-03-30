// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract MyToken {
    address public owner;
    mapping (address => uint256) public balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Sell(address indexed from, uint256 value);

    constructor() {
        owner = msg.sender;
    }
    
    // returns total amounut of minted tokens
    function totalSupply() public view {

    }

    // returns the amount of tokens an address owns
    function balanceOf(address account) public returns (uint256) {

    }

    // returns a string with the token's name
    function getName() public view returns (string memory) {

    }

    // returns a string with the token's symbol
    function getSymbol() public view returns (string memory) {

    }

    // returns the token's price at which users can redeem their tokens
    function getPrice() public view returns (uint128) {

    }

    // add function descriptors
    // transfers 'value' amount of tokens between caller's address and the address to
    function transfer(address to, uint256 value) public {

    }

    // enable the OWNER to create 'value' new tokens and give them to address 'to'
    function mint(address to, uint256 value) public {
        require(msg.sender == owner);

    }

    // enables the user to sell tokens for wei at a price of 600 wei per token
    function sell(uint256 value) public {

    }

    // enables the OWNER to destroy the contract, contracts's balance should be transferred to owner
    function close() public {

    }

    /* 
        - executed when a contract receives a transaction that does not match any of 
        its defined functions
        
        - enables anyone to send Ether to the contract's account
    */
    fallback() external {

    }
}