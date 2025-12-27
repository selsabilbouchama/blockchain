// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ScientificClubElection {
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    enum ElectionState { NotStarted, Ongoing, Ended }
    ElectionState public electionState;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(address => Voter) public voters;
    // NEW: We need this array to know which addresses to reset later
    address[] public voterAddresses; 

    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    event VoterRegistered(address voter);
    event CandidateAdded(uint candidateId, string name);
    event VoteCast(address voter, uint candidateId);
    event VotingStarted();
    event VotingEnded();
    event ElectionReset(); // NEW EVENT

    constructor() {
        admin = msg.sender;
        electionState = ElectionState.NotStarted;
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");

        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false
        });
        
        voterAddresses.push(_voter); // Store the address
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

    // --- NEW RESET FUNCTION ---
    function resetElection() public onlyAdmin {
        // 1. Reset Election State
        electionState = ElectionState.NotStarted;

        // 2. Clear Candidates mapping
        for (uint i = 1; i <= candidatesCount; i++) {
            delete candidates[i];
        }
        candidatesCount = 0;

        // 3. Reset all registered voters' 'hasVoted' status
        for (uint i = 0; i < voterAddresses.length; i++) {
            address voterAddr = voterAddresses[i];
            voters[voterAddr].hasVoted = false;
        }

        emit ElectionReset();
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

    function vote(uint _candidateId) public {
        require(electionState == ElectionState.Ongoing, "Voting is not active");
        require(voters[msg.sender].isRegistered, "You are not a registered voter");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");

        voters[msg.sender].hasVoted = true;
        candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _candidateId);
    }

    function getCandidate(uint _candidateId)
        public
        view
        returns (uint id, string memory name, uint voteCount)
    {
        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }
}