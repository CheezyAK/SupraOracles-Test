// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    address public owner;
    mapping(address => bool) public registeredVoters;
    mapping(address => bool) public hasVoted;
    mapping(bytes32 => uint256) public votesReceived;

    event VoterRegistered(address indexed voter);
    event CandidateAdded(bytes32 indexed candidate);
    event VoteCasted(address indexed voter, bytes32 indexed candidate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(registeredVoters[msg.sender], "Only registered voters can call this function");
        _;
    }

    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerVoter() external {
        require(!registeredVoters[msg.sender], "You are already registered");
        registeredVoters[msg.sender] = true;
        emit VoterRegistered(msg.sender);
    }

    function addCandidate(bytes32 _candidate) external onlyOwner {
        votesReceived[_candidate] = 0;
        emit CandidateAdded(_candidate);
    }

    function castVote(bytes32 _candidate) external onlyRegisteredVoter hasNotVoted {
        require(votesReceived[_candidate] != uint256(type(uint256).max), "Invalid candidate");
        votesReceived[_candidate]++;
        hasVoted[msg.sender] = true;
        emit VoteCasted(msg.sender, _candidate);
    }

    function getVotesForCandidate(bytes32 _candidate) external view returns (uint256) {
        require(votesReceived[_candidate] != uint256(type(uint256).max), "Invalid candidate");
        return votesReceived[_candidate];
    }
}
