// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./customLib.sol";

contract MyToken {
    address payable private owner;
    // address private _libraryAddress;

    string private name;
    string private symbol;

    uint256 private totalSupplyOfTokens;
    uint128 private price;

    bool closedContract;

    mapping(address => uint256) private balances;
    mapping(address => bool) private transferLock;
    mapping(address => bool) private sellLock;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Sell(address indexed from, uint256 value);

    constructor() {
        owner = payable(msg.sender);
        name = "Fresca Coin";
        symbol = "FSC";
        price = 600 wei;
        closedContract = false;
        // _libraryAddress = 0x9DA4c8B1918BA29eBA145Ee3616BCDFcFAA2FC51;
    }

    fallback() external payable {
        // QUESTION: why do we use fallback instead of receive??
        // - receive function is specifically used to receive Ether
    }

    function sendEth(address receiver, uint256 value) external payable {
        require(receiver != address(0), "You cannot send ether to the null address.");
        require(!closedContract, "Contract is closed");
        customLib.customSend(value, receiver);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(!closedContract, "Contract is closed");
        require(value > 0, "Value must be greater than zero");
        require(value <= balances[msg.sender], "Insufficient Balance");
        require(to != address(0), "Cannot transfer to the zero address");
        
        bool guard = transferLock[msg.sender];
        transferLock[msg.sender] = true;
        require(!guard, "Reentrant call detected");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);

        transferLock[msg.sender] = false;

        return true;
    }

    // QUESTION: Should owner be allowed to mint unlimited amount of tokens?
    function mint(address to, uint256 value) public returns (bool) {
        require(!closedContract, "Contract is closed");
        require(msg.sender == owner, "Only the owner can mint new tokens");
        require(to != address(0), "You cannot mint to the zero addresss");

        totalSupplyOfTokens += value;
        balances[to] += value;

        emit Mint(to, value);

        return true;
    }

    function sell(uint256 value) public returns (bool) {
        require(!closedContract, "Contract is closed");
        require(value <= balances[msg.sender], "Insufficient Balance");

        uint256 sellingPrice = price * value;
        require(address(this).balance >= sellingPrice, "Contract does not have enough funds to buy tokens");
        
        bool guard = sellLock[msg.sender];
        sellLock[msg.sender] = true;
        require(!guard, "Reentrant call detected");

        balances[msg.sender] -= value;
        totalSupplyOfTokens -= value;
        payable(msg.sender).transfer(sellingPrice);

        emit Sell(msg.sender, value);

        sellLock[msg.sender] = false;

        return true;
    }

    function close() public {
        require(!closedContract, "Contract is closed");
        require(msg.sender == owner, "Only the owner can close the contract");

        uint256 contractBalance = address(this).balance;
        owner.transfer(contractBalance);

        closedContract = true;
    }

    function totalSupply() public view returns (uint256) {
        require(!closedContract, "Contract is closed");
        return totalSupplyOfTokens;
    }

    function balanceOf(address account) public view returns (uint256) {
        require(!closedContract, "Contract is closed");
        return balances[account];
    }

    function getName() public view returns (string memory) {
        require(!closedContract, "Contract is closed");
        return name;
    }

    function getSymbol() public view returns (string memory) {
        require(!closedContract, "Contract is closed");
        return symbol;
    }

    // QUESTION: How do the price of tokens change?
    function getPrice() public view returns (uint128) {
        require(!closedContract, "Contract is closed");
        return price;
    }
}