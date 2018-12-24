pragma solidity ^0.4.24;

contract RewardPoints {
    address private owner;
    mapping(address => bool) private isAdmin; // Quick way to check if an addr is an Admin

    struct Merchant {
        uint id;
        address addr; // the organization's owner address
        bool isApproved;
        mapping(address => bool) isOperator; // is addr approved by Merchant as operator
    }
    Merchant[] private merchants;
    mapping(address => uint) private addrToMerchantId; // get merchantId from an addr

    struct User {
        uint id;
        address addr;
        bool isApproved;
        uint totalEarnedPoints;
        uint totalReedemedPoints;
        mapping(uint => uint) merchantToEarnedPts; // keep track of points earned from each merchant separately
        mapping(uint => uint) merchantToRedeemedPts; // keep track of points used for at each merchant
    }
    User[] private users;
    mapping(address => uint) private addrToUserId;


    // =================================
    // Events and modifiers
    // =================================
    event AddedAdmin(address indexed admin);
    event RemovedAdmin(address indexed admin);

    event AddedMerchant(address indexed merchant, uint indexed id);
    event BannedMerchant(uint indexed merchantId);
    event ApprovedMerchant(uint indexed merchantId);
    event TransferredMerchantOwnership(uint indexed merchantId, address oldOwner, address newOwner);

    event AddedOperator(uint indexed merchantId, address indexed operator);
    event RemovedOperator(uint indexed merchantId, address indexed operator);

    event AddedUser(address indexed user, uint indexed id);
    event BannedUser(address indexed user, uint indexed id);
    event ApprovedUser(address indexed user, uint indexed id);

    event RewardedUser(address indexed user, uint indexed merchantId, uint points);
    event RedeemedPoints(address indexed user, uint indexed merchantId, uint points);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this operation");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] || msg.sender == owner, "sender is not admin");
        _;
    }

    function merchantExist(uint _id) internal view returns(bool) {
        if (_id != 0 && _id < merchants.length) return true;
        return false;
    }

    function isMerchantValid(uint _id) internal view returns(bool) {
        if(merchantExist(_id) && merchants[_id].isApproved) return true;
        return false;
    }

    function isMerchantOwner(address _owner) internal view returns(bool) {
        uint id = addrToMerchantId[_owner];
        return (isMerchantValid(id) && merchants[id].addr == _owner);
    }

    modifier onlyMerchantOwner() {
        require(isMerchantOwner(msg.sender), "merchant is not owner");
        _;
    }

    modifier onlyMerchant() {
        uint id = addrToMerchantId[msg.sender];
        bool isOperator = merchants[id].isOperator[msg.sender];
        require(isMerchantValid(id));
        require(isMerchantOwner(msg.sender) || isOperator);
        _;
    }

    function userExist(uint _id) internal view returns(bool) {
        if(_id != 0 && _id < users.length) return true;
        return false;
    }

    function isUserValid(uint _id) internal view returns(bool) {
        if(userExist(_id) && users[_id].isApproved) return true;
        return false;
    }

    modifier onlyUser() {
        require(isUserValid(addrToUserId[msg.sender]), "not a valid user");
        _;
    }

    constructor() public {
        // Do not use ID 0 for first user and merchant to avoid returning invalid
        // first merchant/user when looking it up with addrToMerchantID mapping
        merchants.push(Merchant(0, 0, false));
        users.push(User(0, 0, false, 0, 0));
        owner = msg.sender;
    }

    // =================================
    // Owner Only
    // =================================
    function addAdmin(address _admin) external onlyOwner {
        // TODO: your code here
        isAdmin[_admin] = true;
        
        emit AddedAdmin(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        // TODO: your code here
        isAdmin[_admin] = false;
        
        emit RemovedAdmin(_admin);
    }

    // =================================
    // Admin Only Actions
    // =================================
    function addMerchant(address _merchant) external onlyAdmin {
        // TODO: your code here
        // Hints: Remember the index into the array is the ID
        
        // 1. Create a new merchant and assign various fields
        Merchant memory new_merchant;
        new_merchant.id = merchants.length;
        new_merchant.addr = _merchant;
        new_merchant.isApproved = false;

        // 2. Push new merchant into array
        merchants.push(new_merchant);

        merchants[new_merchant.id].isOperator[_merchant] = true;
        
        // 3. Update addrToMerchantId mapping
        addrToMerchantId[_merchant] = new_merchant.id;

        // 4. Emit event
        emit AddedMerchant(_merchant, new_merchant.id);
    }

    function banMerchant(uint _id) external onlyAdmin {
        // TODO: your code here
        // Hints: Only ban merchants that are valid and
        // remember we're not removing a merchant.
        merchants[_id].isApproved = false;
        
        emit BannedMerchant(_id);
    }

    function approveMerchant(uint _id) external onlyAdmin {
        // TODO: your code here
        // Hints: Do the reverse of banMerchant
        merchants[_id].isApproved = true;
        
        emit ApprovedMerchant(_id);
    }

    function addUser(address _user) external onlyAdmin {
        // TODO: your code here
        // Hints: Similar steps to addMerchant

        User memory new_user;
        new_user.id = users.length;
        new_user.addr = _user;
        new_user.isApproved = false;
        new_user.totalEarnedPoints = 0;
        new_user.totalReedemedPoints = 0;

        users.push(new_user);

        addrToUserId[_user] = new_user.id;

        emit AddedUser(_user, new_user.id);
    }

    function banUser(address _user) external onlyAdmin {
        // TODO: your code here
        // Hints: Similar to banMerchant but the input
        // parameter is user address instead of ID.
        users[addrToUserId[_user]].isApproved = false;

        emit BannedUser(_user, addrToUserId[_user]);
    }

    function approveUser(address _user) external onlyAdmin {
        // TODO: your code here
        // Hints: Do the reverse of banUser
        users[addrToUserId[_user]].isApproved = true;

        emit ApprovedUser(_user, addrToUserId[_user]);
    }

    // =================================
    // Merchant Owner Only Actions
    // =================================
    function addOperator(address _operator) external onlyMerchantOwner {
        // TODO: your code here
        // Hints:
        // 1. Get the merchant ID from msg.sender
        uint merchantId = addrToMerchantId[msg.sender];

        // 2. Set the correct field within the Merchant Struct
        merchants[merchantId].isOperator[_operator] = true;

        // 3. Update addrToMerchantId mapping
        addrToMerchantId[_operator] = merchantId;

        // 4. Emit event
        emit AddedOperator(merchantId, _operator);
    }

    function removeOperator(address _operator) external onlyMerchantOwner {
        // TODO: your code here
        // Hints: Do the reverse of addOperator
        // 1. Get the merchant ID from msg.sender
        uint merchantId = addrToMerchantId[msg.sender];

        // 2. Set the correct field within the Merchant Struct
        merchants[merchantId].isOperator[_operator] = false;

        // 3. Update addrToMerchantId mapping
        addrToMerchantId[_operator] = merchantId;

        // 4. Emit event
        emit RemovedOperator(merchantId, _operator);
    }

    function transferMerchantOwnership(address _newAddr) external onlyMerchantOwner {
        // TODO: your code here
        // Hints: Similar to addOperator but update different fields
        // but remember to update the addrToMerchantId twice. Once to
        // remove the old owner and once for the new owner.
        uint merchantId = addrToMerchantId[msg.sender];

        merchants[merchantId].addr = _newAddr;

        addrToMerchantId[_newAddr] = merchantId;
        delete addrToMerchantId[msg.sender];
        // 4. Emit event
        emit TransferredMerchantOwnership(merchantId, msg.sender, _newAddr);
    }

    // =================================
    // Merchant only actions
    // =================================
    function rewardUser(address _user, uint _points) external onlyMerchant {
        // TODO: your code here
        // Hints: update the total and per merchant points
        // for the user in the User struct.
        uint userId = addrToUserId[_user];
        require(userExist(userId), "user does not exist");
        require(isUserValid(userId), "not a valid user");
        uint merchantId = addrToMerchantId[msg.sender];

        users[userId].totalEarnedPoints += _points;
        users[userId].merchantToEarnedPts[merchantId] += _points;

        emit RewardedUser(_user, merchantId, _points);
    }

    // =================================
    // User only action
    // =================================
    function redeemPoints(uint _mId, uint _points) external onlyUser {
        // TODO: your code here
        // Hints:
        // 1. Get the user ID from caller
        // 2. Ensure user has at least _points at merchant with id _mID
        // 3. Update the appropriate fields in User structs
        // 4. Emit event
        uint userId = addrToUserId[msg.sender];
        require(merchantExist(_mId), "merchant does not exist");

        uint pointsAvailable = users[userId].merchantToEarnedPts[_mId] - users[userId].merchantToRedeemedPts[_mId];
        require(pointsAvailable >= _points,"not enough points");

        users[userId].totalReedemedPoints -= _points;
        users[userId].merchantToRedeemedPts[_mId] += _points;

        emit RedeemedPoints(msg.sender, _mId, _points);
    }

    // =================================
    // Getters
    // =================================

    function getMerchantById(uint _id) public view returns(uint, address, bool) {
        require(merchantExist(_id), "merchant does not exist");
        Merchant storage m = merchants[_id];
        return(m.id, m.addr, m.isApproved);
    }

    function getMerchantByAddr(address _addr) public view returns(uint, address, bool) {
        uint id = addrToMerchantId[_addr];
        return getMerchantById(id);
    }

    function isMerchantOperator(address _operator, uint _mId) public view returns(bool) {
        require(merchantExist(_mId), "merchant does not exist");
        return merchants[_mId].isOperator[_operator];
    }

    function getUserById(uint _id) public view returns(uint, address, bool, uint, uint) {
        require(userExist(_id), "user does not exist");
        User storage u = users[_id];
        return(u.id, u.addr, u.isApproved, u.totalEarnedPoints, u.totalReedemedPoints);
    }

    function getUserByAddr(address _addr) public view returns(uint, address, bool, uint, uint) {
        uint id = addrToUserId[_addr];
        return getUserById(id);
    }

    function getUserEarnedPointsAtMerchant(address _user, uint _mId) public view returns(uint) {
        uint uId = addrToUserId[_user];
        require(userExist(uId), "user does not exist");
        require(merchantExist(_mId), "merchant does not exist");
        return users[uId].merchantToEarnedPts[_mId];
    }

    function getUserRedeemedPointsAtMerchant(address _user, uint _mId) public view returns(uint) {
        uint uId = addrToUserId[_user];
        require(userExist(uId), "user does not exist");
        require(merchantExist(_mId), "merchant does not exist");
        return users[uId].merchantToRedeemedPts[_mId];
    }

}