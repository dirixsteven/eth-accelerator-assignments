var Election = artifacts.require('Election');
var { expectThrow, expectEvent } = require('./helpers.js');

contract('Election contract Tests', async (accounts) => {
    let owner = accounts[0];
    let voter1 = accounts[1];
    let voter2 = accounts[2];
    let contract;

    let getCandidate = async (id) => {
        let candidate = await contract.candidates.call(id);
        let name = candidate[0];
        let votes = parseInt(candidate[1]); // convert from BN to int
        return {name: name, votes: votes};
    }

    beforeEach(async () => {
        contract = await Election.deployed();
    })

    describe('constructor() test', () => {
        it('election name should be set in constructor', async() => {
            let name = await contract.name.call();
            assert.notEqual(name, "");
        });
    
        it('should not have any candidates', async() => {
            let length = await contract.getNumCandidate.call();
            assert.equal(length, 0);
        })
    })

    describe('addCandidate() tests', () => {
        it('owner can add candidates', async () => {
            await contract.addCandidate("Jon Snow", { from: owner });
        })

        it('non owner can not add candidates', async () => {
            let tx = contract.addCandidate('Jon Snow', { from: voter1 });
            await expectThrow(tx);
        })

        it('candidate info check', async() => {
            let candidate = await getCandidate(0);
            assert.equal(candidate.name, "Jon Snow");
            assert.equal(candidate.votes, 0);
        })
    })

    describe('authorize() tests', () => {
        it('non owner can not authorize voter', async () => {
            let tx = contract.authorize(voter1, { from: voter2 });
            await expectThrow(tx);
        })

        it('owner can authorize voter', async () => {
            await contract.authorize(voter1, { from: owner });
        })
    })

    describe('vote() tests', () => {
        it('non authorized users can not vote', async () => {
            let tx = contract.vote(0, { from: owner });
            await expectThrow(tx);
        })

        it('authorized voters can vote', async () => {
            let tx = contract.vote(0, { from: voter1 });
            await expectEvent(tx, "Vote");
        })

        it('candidate votes should be updated', async() => {
            let candidate = await getCandidate(0);
            assert.equal(candidate.votes, 1);
        })
    })
})

