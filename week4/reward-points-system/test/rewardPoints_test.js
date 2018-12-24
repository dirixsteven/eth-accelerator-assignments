var RewardPoints = artifacts.require('RewardPoints');
var { expectThrow, expectEvent } = require('./helpers.js');

contract('RewardPoints Tests', async (accounts) => {
    let owner = accounts[0];
    let admin1 = accounts[1];
    let admin2 = accounts[2];
    let merchant1 = accounts[3];
    let merchant2 = accounts[4];
    let user1 = accounts[5];
    let user2 = accounts[6];
    let operator = accounts[7];
    let newMerchant = accounts[8];

    let contract;

    beforeEach(async () => {
        contract = await RewardPoints.deployed();
    })

    describe('constructor() test', () => {
        it('dummy merchant and user created', async() => {

        })
    
        it('should not have any users', async() => {
            let tx = contract.getUserById(0);
            await expectThrow(tx);
        })

        it('should not have any merchants', async() => {
            let tx = contract.getMerchantById(0);
            await expectThrow(tx);
        })
    })

    describe('addAdmin() tests', () => {
        it('only owner can add admins', async() => {
            let tx = contract.addAdmin(admin1, {from: owner});
            await expectEvent(tx, "AddedAdmin");
        })

        it('non owner cannot add admins', async() => {
            let tx = contract.addAdmin(admin2, {from: admin1});
            await expectThrow(tx);
        })
    })

    describe('removeAdmin() tests', () => {
        it('only owner can remove admins', async() => {
            await contract.addAdmin(admin2, {from: owner});
            let tx = contract.removeAdmin(admin2, {from: owner});
            await expectEvent(tx, "RemovedAdmin");
        })

        it('non owner cannot remove admins', async() => {
            await contract.addAdmin(admin2, {from: owner});
            let tx = contract.removeAdmin(admin2, {from: admin1});
            await expectThrow(tx);
        })
    })

    describe('addMerchant() tests', () => {
        it('only owners and admins can add merchants', async() => {
            let tx = contract.addMerchant(merchant1, {from: owner});
            await expectEvent(tx, "AddedMerchant");
            tx = contract.addMerchant(merchant2, {from: admin1});
            await expectEvent(tx, "AddedMerchant");
        })

        it('merchant info check', async() => {
            let merchant = await contract.getMerchantById(1);
            assert.equal(merchant[0], 1);
            assert.equal(merchant[2], false);
        })

        it('non owners and admins can not add merchants', async() => {
            let tx = contract.addMerchant(user1, {from: merchant1});
            await expectThrow(tx);
        })
    })

    describe('banMerchant() and approveMerchant() tests', () => {
        it('only owners and admins can ban and approve merchants', async() => {
            let tx = contract.approveMerchant(1, {from: owner});
            await expectEvent(tx, "ApprovedMerchant");
            let merchant = await contract.getMerchantById(1);
            assert.equal(merchant[2], true);
            
            tx = contract.banMerchant(1, {from: owner});
            await expectEvent(tx, "BannedMerchant");
            merchant = await contract.getMerchantById(1);
            assert.equal(merchant[2], false);
            
            tx = contract.approveMerchant(1, {from: admin1});
            await expectEvent(tx, "ApprovedMerchant");
            merchant = await contract.getMerchantById(1);
            assert.equal(merchant[2], true);
            
        })

        it('non owners and admins can not ban or approve merchants', async() => {
            let tx = contract.approveMerchant(2, {from: merchant1});
            await expectThrow(tx);
            let merchant = await contract.getMerchantById(2);
            assert.equal(merchant[2], false);

            await contract.approveMerchant(2, {from: admin1});

            tx = contract.banMerchant(2, {from: merchant1});
            await expectThrow(tx);
            merchant = await contract.getMerchantById(2);
            assert.equal(merchant[2], true);
        })
    })

    describe('addUser() tests', () => {
        it('only owners and admins can add users', async() => {
            let tx = contract.addUser(user1, {from: owner});
            await expectEvent(tx, "AddedUser");
            tx = contract.addUser(user2, {from: admin1});
            await expectEvent(tx, "AddedUser");
        })

        it('user info check', async() => {
            let user = await contract.getUserById(1);
            assert.equal(user[0], 1);
            assert.equal(user[2], false);
            assert.equal(user[3], 0);
            assert.equal(user[4], 0);
            user = await contract.getUserById(2);
            assert.equal(user[0], 2);
            assert.equal(user[2], false);
            assert.equal(user[3], 0);
            assert.equal(user[4], 0);
        })

        it('non owners and admins can not add users', async() => {
            let tx = contract.addUser(merchant2, {from: merchant1});
            await expectThrow(tx);
        })
    })

    describe('banUser() and approveUser() tests', () => {
        it('only owners and admins can ban and approve users', async() => {
            let user = await contract.getUserById(1);
            let tx = contract.approveUser(user[1], {from: owner});
            await expectEvent(tx, "ApprovedUser");
            user = await contract.getUserById(1);
            assert.equal(user[2], true);
            
            tx = contract.banUser(user[1], {from: owner});
            await expectEvent(tx, "BannedUser");
            user = await contract.getUserById(1);
            assert.equal(user[2], false);
            
            tx = contract.approveUser(user[1], {from: admin1});
            await expectEvent(tx, "ApprovedUser");
            user = await contract.getUserById(1);
            assert.equal(user[2], true);
            
        })

        it('non owners and admins can not ban or approve users', async() => {
            let user = await contract.getUserById(2);
            let tx = contract.approveUser(user[1], {from: merchant1});
            await expectThrow(tx);

            await contract.approveUser(user[1], {from: admin1});

            tx = contract.banUser(user[1], {from: user1});
            await expectThrow(tx);
        })
    })

    describe('addOperator() and removeOperator() tests', () => {
        it('only merchant owner can add operator', async() => {
            let tx = contract.addOperator(operator, {from: merchant1});
            await expectEvent(tx, "AddedOperator");
            assert.equal(await contract.isMerchantOperator(operator, 1), true);
        })

        it('non merchant owner cannot add operator', async() => {
            let tx = contract.addOperator(operator, {from: owner});
            await expectThrow(tx);
        })

        it('only merchant owner can remove operator', async() => {
            let tx = contract.removeOperator(operator, {from: merchant1});
            await expectEvent(tx, "RemovedOperator");
            assert.equal(await contract.isMerchantOperator(operator, 1), false);
        })

        it('non merchant owner cannot remove operator', async() => {
            await contract.addOperator(operator, {from: merchant1});
            let tx = contract.removeOperator(operator, {from: owner});
            await expectThrow(tx);
            assert.equal(await contract.isMerchantOperator(operator, 1), true);
        })
    })

    describe('transferMerchantOwnership() tests', () => {
        it('only merchant owner can transfer ownership', async() => {
            let tx = contract.transferMerchantOwnership(newMerchant, {from: merchant1});
            await expectEvent(tx, 'TransferredMerchantOwnership');
            let merchant = await contract.getMerchantByAddr(newMerchant);
            assert.equal(merchant[0], 1);
        })

        it('non merchant owner can not transfer ownership', async() => {
            let tx = contract.transferMerchantOwnership(merchant1, {from: operator});
            await expectThrow(tx);
            let merchant = await contract.getMerchantByAddr(newMerchant);
            assert.equal(merchant[0], 1);
        })
    })

    describe('rewardUser() tests', () => {
        it('only merchant can reward user', async() => {
            let tx = contract.rewardUser(user1, 100, {from: operator});
            await expectEvent(tx, "RewardedUser");
            tx = contract.rewardUser(user1, 100, {from: owner});
            await expectThrow(tx);
        })

        it('get earned points of user1', async() => {
            let earnedPoints = await contract.getUserEarnedPointsAtMerchant(user1, 1);
            assert.equal(earnedPoints, 100);
        })
    })

    describe('redeemPoints() tests', () => {
        it('only user can redeem points', async() => {
            let tx = contract.redeemPoints(1, 75, {from: user1});
            await expectEvent(tx, "RedeemedPoints");
            tx = contract.redeemPoints(1, 25, {from: owner});
            await expectThrow(tx);
        })

        it('user cannot redeem more points than earned', async() => {
            let tx = contract.redeemPoints(1, 50, {from: user1});
            await expectThrow(tx);
        })
    })



    /*
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
    */
})

