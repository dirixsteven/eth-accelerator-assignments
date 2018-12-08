pragma solidity ^0.4.25;

/*
Election contract that allows the owner to issue voting rights
to anybody and also end the election and announce results
*/
contract Election {
    address public owner;
    string public name;
    
    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    
    struct Candidate {
        string name;
        uint voteCount;
    }
    
    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
    }
    
    event ElectionResult(string candidateName, uint voteCount);
    
    constructor(string _name, string _candidate1, string _candidate2) public {
        owner = msg.sender;
        name = _name;
        
        candidates.push(Candidate(_candidate1, 0));
        candidates.push(Candidate(_candidate2, 0));
    }
    
    function authorize(address _voter) public {
        require(msg.sender == owner, "Only owner can authorize voting rights");
        require(!voters[_voter].voted, "Voter already voted");
        
        voters[_voter].authorized = true;
    }
    
    function vote(uint _candidate) public {
        require(voters[msg.sender].authorized, "Not authorized to vote"); // Step 1: caller is authorized to vote
        require(!voters[msg.sender].voted, "Voter already voted"); // Step 2: make sure the voter did not vote already
        require(_candidate < candidates.length, "Not a valid candidate"); // Step 3: make sure they're voting for a candidate that exists
        
        voters[msg.sender].vote = _candidate; // Step 4: track who the voter voted for
        voters[msg.sender].voted = true; // Step 5: mark voter has voted
        candidates[_candidate].voteCount += 1; // Step 6: update the candidate's vote count
    }
    
    function end() public {
        require(msg.sender == owner, "Only owner can end election");
        
        // Emit event for each candidates results
        for (uint i=0; i < candidates.length; i++) {
            emit ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
    }
}