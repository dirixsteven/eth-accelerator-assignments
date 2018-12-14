pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "../contracts/Election.sol";
import "./ThrowProxy.sol";

contract TestElection {
    Election instance = new Election("My Election");
    address public account1 = 0xB2d44dF1e135Fb36Cc7b049b0Ff671c8c0a3EC13;
    address public account2 = 0x26E74F801Dda9A011Af02Ca7FCE38Ad1492CD963;

    function testElectionNameIsSet() public {
        string memory name = instance.name();
        Assert.notEqual(name, "", "election name should be set in constructor");
    }

    function testCandidateCountIsZero() public {
        uint candidateCount = instance.getNumCandidate();
        Assert.equal(candidateCount, 0, "election should not have any candidates");
    }

    function testOwnerCanAddCandidates() public {
        instance.addCandidate("Jon Snow");
        uint candidateCount = instance.getNumCandidate();

        Assert.equal(candidateCount, 1, "owner can add candidates");
    }

    function testNonOwnerCannotAddCandidates() public {
        ThrowProxy proxy = new ThrowProxy(address(instance));
        Election(address(proxy)).addCandidate("Jon Snow");

        bool result = proxy.execute();

        Assert.isFalse(result, "non-owner cannot add candidates");
    }

    function testOwnerCanAuthorize() public {
        instance.authorize(account1);
        bool authorized = instance.getAuthorized(account1);

        Assert.isTrue(authorized, "owner can authorize");
    }

    function testNonOwnerCannotAuthorize() public {
        ThrowProxy proxy = new ThrowProxy(address(instance));
        Election(address(proxy)).authorize(account1);

        bool result = proxy.execute();

        Assert.isFalse(result, "non-owner cannot authorize");
    }

    function testAuthorizedUserCanVote() public {
        ThrowProxy proxy = new ThrowProxy(account1);
        Election(address(proxy)).vote(0);

        bool result = proxy.execute();
        //uint voteCount = instance.getVoteCount(0);

        Assert.isTrue(result, "authorized users can vote");
        //Assert.equal(voteCount, 1, "voteCount has increased");
    }

    function testNonAuthorizedUsersCannotVote() public {
        ThrowProxy proxy = new ThrowProxy(account2);
        Election(address(proxy)).vote(0);

        bool result = proxy.execute();

        Assert.isFalse(result, "non-authorized users cannot vote");
    }
}