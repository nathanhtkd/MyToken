// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./customLib.sol";

contract MyToken {
    address payable private _owner;
    address constant owner = 0xC8e8aDd5C59Df1B0b2F2386A4c4119aA1021e2Ff;
    // address private _libraryAddress;

    string private name;
    string private symbol;

    uint256 private totalSupplyOfTokens;
    uint128 private constant PRICE = 600 wei;

    mapping(address => uint256) private balances;
    mapping(address => bool) private transferLock;
    mapping(address => bool) private sellLock;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Sell(address indexed from, uint256 value);

    constructor() {
        _owner = payable(msg.sender);
        name = "Fresca Coin";
        symbol = "FSC";
    }

    fallback() external payable {
        // QUESTION: why do we use fallback instead of receive??
        // - receive function is specifically used to receive Ether
    }

    function sendEth(address receiver, uint256 value) external payable {
        require(receiver != address(0), "You cannot send ether to the null address.");
        address customLibAddr = 0x9DA4c8B1918BA29eBA145Ee3616BCDFcFAA2FC51;
        (bool success, ) = customLibAddr.delegatecall(abi.encodeWithSignature("customSend(uint256,address)", value, receiver));
        require(success, "Delegate call failed");
    }

    function transfer(address to, uint256 value) public returns (bool) {
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
        require(msg.sender == _owner, "Only the owner can mint new tokens");
        require(to != address(0), "You cannot mint to the zero addresss");

        totalSupplyOfTokens += value;
        balances[to] += value;

        emit Mint(to, value);

        return true;
    }

    function sell(uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient Balance");

        uint256 sellingPrice = PRICE * value;
        require(
            address(this).balance >= sellingPrice,
            "Contract does not have enough funds to buy tokens"
        );

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
        require(msg.sender == _owner, "Only the owner can close the contract");

        uint256 contractBalance = address(this).balance;
        _owner.transfer(contractBalance);

        selfdestruct(_owner);
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

    // QUESTION: How do the price of tokens change?
    function getPrice() public pure returns (uint128) {
        return PRICE;
    }
}
