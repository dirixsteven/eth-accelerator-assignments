pragma solidity ^0.4.25;

contract Escrow {

    enum State {AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED}
    State public currentState;

    address public buyer;
    address public seller;
    address public arbiter;

    modifier buyerOnly() {
        require(msg.sender == buyer || msg.sender == arbiter);
        _;
    }
    
    modifier inState(State expectedState) {
        require(currentState == expectedState);
        _;
    }
    
    modifier sellerOnly() {
        require(msg.sender == seller || msg.sender == arbiter);
        _;
    }
    
    constructor(address _buyer, address _seller, address _arbiter) public {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }
    
    function sendPayment() public payable buyerOnly inState(State.AWAITING_PAYMENT) {
        currentState = State.AWAITING_DELIVERY;
    }
    
    function confirmDelivery() public buyerOnly inState(State.AWAITING_DELIVERY) {
        seller.transfer(address(this).balance);
        currentState = State.COMPLETE;
    }
    
    function refundBuyer() sellerOnly inState(State.AWAITING_DELIVERY) public {
        buyer.transfer(address(this).balance);
        currentState = State.REFUNDED;
    }
}