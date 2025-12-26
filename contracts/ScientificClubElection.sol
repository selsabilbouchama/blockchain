// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ScientificClubElection {

    // -----------------------------
    // ADMIN
    // -----------------------------
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // -----------------------------
    // ELECTION STATE
    // -----------------------------
    enum ElectionState { NotStarted, Ongoing, Ended }
    ElectionState public electionState;

    // -----------------------------
    // DATA STRUCTURES
    // -----------------------------
    struct Voter {
        bool isRegistered;
        bool hasVoted;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // -----------------------------
    // STORAGE
    // -----------------------------
    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    // -----------------------------
    // EVENTS
    // -----------------------------
    event VoterRegistered(address voter);
    event CandidateAdded(uint candidateId, string name);
    event VoteCast(address voter, uint candidateId);
    event VotingStarted();
    event VotingEnded();

    // -----------------------------
    // CONSTRUCTOR
    // -----------------------------
    constructor() {
        admin = msg.sender;
        electionState = ElectionState.NotStarted;
    }

    // -----------------------------
    // ADMIN FUNCTIONS
    // -----------------------------
    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");

        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false
        });

        emit VoterRegistered(_voter);
    }

    function addCandidate(string memory _name) public onlyAdmin {
        require(electionState == ElectionState.NotStarted, "Cannot add candidates after voting starts");

        candidatesCount++;
        candidates[candidatesCount] = Candidate({
            id: candidatesCount,
            name: _name,
            voteCount: 0
        });

        emit CandidateAdded(candidatesCount, _name);
    }

    function startVoting() public onlyAdmin {
        require(electionState == ElectionState.NotStarted, "Voting already started or ended");

        electionState = ElectionState.Ongoing;
        emit VotingStarted();
    }

    function endVoting() public onlyAdmin {
        require(electionState == ElectionState.Ongoing, "Voting is not ongoing");

        electionState = ElectionState.Ended;
        emit VotingEnded();
    }

    // -----------------------------
    // VOTER FUNCTION
    // -----------------------------
    function vote(uint _candidateId) public {
        require(electionState == ElectionState.Ongoing, "Voting is not active");
        require(voters[msg.sender].isRegistered, "You are not a registered voter");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");

        voters[msg.sender].hasVoted = true;
        candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _candidateId);
    }

    // -----------------------------
    // VIEW FUNCTIONS
    // -----------------------------
    function getCandidate(uint _candidateId)
        public
        view
        returns (uint id, string memory name, uint voteCount)
    {
        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }
}
