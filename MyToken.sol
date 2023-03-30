// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./customLib.sol";

contract MyToken {
    address payable private owner;
    // address private _libraryAddress;

    string private name;
    string private symbol;

    uint256 private totalSupplyOfTokens;
    uint128 private price;

    mapping(address => uint256) private balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Sell(address indexed from, uint256 value);

    constructor() {
        // QUESTION: Does defining state variables incur extra gas charges?
        owner = payable(msg.sender);
        name = "PLACEHOLDER_NAME";
        symbol = "PLACEHOLDER_SYMBOL";
        price = 600 wei;
        // _libraryAddress = 0x9DA4c8B1918BA29eBA145Ee3616BCDFcFAA2FC51;
    }

    fallback() external payable {
        // QUESTION: why do we use fallback instead of receive??
        // - receive function is specifically used to receive Ether
    }

    function sendEth(address receiver, uint256 value) external payable {
        customLib.customSend(value, receiver);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient Balance");
        require(to != address(0), "Cannot transfer to the zero address");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function mint(address to, uint256 value) public returns (bool) {
        // QUESTION: Should owner be allowed to mint unlimited amount of tokens?
        require(msg.sender == owner, "Only the owner can mint new tokens");
        require(to != address(0), "You cannot mint to the zero addresss");

        totalSupplyOfTokens += value;
        balances[to] += value;

        emit Mint(to, value);

        return true;
    }

    function sell(uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient Balance");

        uint256 sellingPrice = price * value;
        require(address(this).balance >= sellingPrice, "Contract does not have enough funds to buy tokens");

        balances[msg.sender] -= value;
        totalSupplyOfTokens -= value;
        payable(msg.sender).transfer(sellingPrice);

        emit Sell(msg.sender, value);

        return true;
    }

    function close() public {
        require(msg.sender == owner, "Only the owner can close the contract");

        uint256 contractBalance = address(this).balance;
        owner.transfer(contractBalance);

        // TODO: can we use selfsdestruct()? compiler states that it is deprecated**
        // selfdestruct(_owner);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupplyOfTokens;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    function getPrice() public view returns (uint128) {
        // QUESTION: How do the price of tokens change?
        return price;
    }
}
