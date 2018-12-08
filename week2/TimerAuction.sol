pragma solidity ^0.4.25;

import "./BaseAuction.sol";
import "./Withdrawable.sol";

contract TimerAuction is BaseAuction, Withdrawable {
    string public item;
    uint public auctionEnd;
    bool public ended;
    uint public maxBid;
    address public maxBidder;
    
    constructor(string _item, uint _durationMinutes) public {
        item = _item;
        auctionEnd = now + (_durationMinutes * 1 minutes);
    }
    
    function bid() external payable {
        require(now < auctionEnd); // Step 1: auction did not end
        require(msg.value > maxBid); // Step 2: the bid by the send is greater than the current bid
        
        // Step 3: refund the previous bid to the previous maxBidder
        if (maxBidder != address(0)) {
            pendingWithdrawals[maxBidder] += maxBid;
        }
        
        // Step 4: update new maxBid and Bidder
        maxBidder = msg.sender;
        maxBid = msg.value;
        
        emit BidAccepted(maxBidder, maxBid); // Step 5: emit BidAccepted event so it can be logged
    }
    
    function end() external ownerOnly {
        // Check that time has expired and can only end once
        require(!ended);
        require(now >= auctionEnd);
        
        // Update internal states and transfer ether to owner
        ended = true;
        owner.transfer(maxBid);
        
        emit AuctionComplete(maxBidder, maxBid); //emit event
    }
}