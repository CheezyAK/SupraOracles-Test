// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.20;
//pragma solidity ^0.5.16;
pragma solidity ^0.8.0;

//import "./contracts/token/ERC20/ERC20.sol";
//import "./contracts/access/Ownable.sol";

import "contracts/ERC20.sol";
import "contracts/Ownable.sol";

contract TokenSale is Ownable {
    ERC20 public token;

    enum SalePhase { NotStarted, Presale, PublicSale, Finished }
    SalePhase public currentPhase;

    uint256 public presaleCap;
    uint256 public publicSaleCap;
    uint256 public minContribution;
    uint256 public maxContribution;

    mapping(address => uint256) public contributions;
    mapping(address => bool) public claimedRefund;

    event Contribution(address indexed contributor, uint256 amount, SalePhase phase);
    event RefundClaimed(address indexed contributor, uint256 amount);

    modifier saleNotFinished() {
        require(currentPhase != SalePhase.Finished, "Sale has finished");
        _;
    }

    constructor(
        address _tokenAddress,
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _minContribution,
        uint256 _maxContribution
    ) {
        token = ERC20(_tokenAddress);
        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
        minContribution = _minContribution;
        maxContribution = _maxContribution;
        currentPhase = SalePhase.NotStarted;
    }

    function startPresale() external onlyOwner {
        require(currentPhase == SalePhase.NotStarted, "Presale has already started");
        currentPhase = SalePhase.Presale;
    }

    function startPublicSale() external onlyOwner {
        require(currentPhase == SalePhase.Presale, "Public sale can only start after presale");
        currentPhase = SalePhase.PublicSale;
    }

    function contribute() external payable saleNotFinished {
        uint256 contributionAmount = msg.value;
        require(contributionAmount >= minContribution, "Contribution below minimum limit");
        require(contributionAmount <= maxContribution, "Contribution exceeds maximum limit");

        if (currentPhase == SalePhase.Presale) {
            require(address(this).balance <= presaleCap, "Presale cap reached");
        } else if (currentPhase == SalePhase.PublicSale) {
            require(address(this).balance <= publicSaleCap, "Public sale cap reached");
        }

        contributions[msg.sender] += contributionAmount;
        token.transfer(msg.sender, contributionAmount);

        emit Contribution(msg.sender, contributionAmount, currentPhase);
    }

    function distributeTokens(address recipient, uint256 amount) external onlyOwner {
        require(currentPhase == SalePhase.Finished, "Tokens can only be distributed after sale ends");
        token.transfer(recipient, amount);
    }

    function claimRefund() external saleNotFinished {
        require(contributions[msg.sender] > 0, "No contribution to claim");

        if (currentPhase == SalePhase.Presale) {
            require(address(this).balance < presaleCap, "Presale cap reached");
        } else if (currentPhase == SalePhase.PublicSale) {
            require(address(this).balance < publicSaleCap, "Public sale cap reached");
        }

        require(!claimedRefund[msg.sender], "Refund already claimed");

        claimedRefund[msg.sender] = true;
        //payable(msg.sender).transfer(contributions[msg.sender]);
        address(uint160(msg.sender)).transfer(contributions[msg.sender]);

        emit RefundClaimed(msg.sender, contributions[msg.sender]);
    }

    function endSale() external onlyOwner {
        require(currentPhase != SalePhase.Finished, "Sale has already ended");
        currentPhase = SalePhase.Finished;
    }
}
