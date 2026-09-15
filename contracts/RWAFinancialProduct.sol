// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RWAFinancialProduct {
        struct Product {
        string name;
        uint256 totalSupply;
        uint256 maturityDate;
        bool redeemed;
    }

    address public owner;

    Product public product;

    mapping(address => uint256) public balances;

    bool public productCreated;
    
    uint256 public allocatedSupply;

    event ProductCreated(
        string name,
        uint256 totalSupply,
        uint256 maturityDate
    );

    event TokensAllocated(
        address indexed investor,
        uint256 amount
    );

    event ProductRedeemed(
        string name
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    function createProduct(
        string memory _name,
        uint256 _totalSupply,
        uint256 _maturityDate
    ) public onlyOwner {
        require(!productCreated, "Product already created");
        require(_totalSupply > 0, "Total supply must be greater than zero");
        require(_maturityDate > block.timestamp, "Maturity must be in the future");
        
        product = Product({
            name: _name,
            totalSupply: _totalSupply,
            maturityDate: _maturityDate,
            redeemed: false //처음등록 했으니 상환되지 않음
        });

        productCreated = true;

        emit ProductCreated(_name, _totalSupply, _maturityDate);
    }

    function allocateTokens(
         address _investor,
         uint256 _amount
    ) public onlyOwner {
         require(productCreated, "Product has not been created");
         require(_investor != address(0), "Invalid investor address");
         require(_amount > 0, "Amount must be greater than zero");
         require(
            allocatedSupply + _amount <= product.totalSupply,
            "Exceeds total supply"
        );

         balances[_investor] += _amount;
         allocatedSupply += _amount;

         emit TokensAllocated(_investor, _amount);

    }
    function redeemProduct() public onlyOwner {
         require(productCreated, "Product has not been created");
         require(!product.redeemed, "Product already redeemed");
         require(block.timestamp >= product.maturityDate, "Product has not matured yet");

         product.redeemed = true;

         emit ProductRedeemed(product.name);
    }
}