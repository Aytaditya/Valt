// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {

// Define the Owner of the smart contract 
address public owner;

constructor() {
        owner = msg.sender;
}

// Create Struct and Mapping for request, transaction & name

struct request {
        address requestor;
        uint256 amountInWei;
        string message;
        string name;
}

struct sendReceive {
        string action;
        uint256 amountInWei;
        string message;
        address otherPartyAddress;
        string otherPartyName;
}

struct userName {
        string name;
        bool hasName;
}

mapping(address => userName) names;
mapping(address => request[]) requests;
mapping(address => sendReceive[]) history;

// Add a name to wallet address

function addName(string memory _name) public {
    userName storage newUserName = names[msg.sender];
    newUserName.name = _name;
    newUserName.hasName = true;
}

// Create a Request

function createRequest(address user, uint256 _amountInEther, string memory _message) public {
    request memory newRequest;
    newRequest.requestor = msg.sender;
    newRequest.amountInWei = _amountInEther * 1 ether; // convert to Wei
    newRequest.message = _message;
    if(names[msg.sender].hasName){
        newRequest.name = names[msg.sender].name;
    }
    requests[user].push(newRequest);
}

// Pay a Request

function payRequest(uint256 _requestIndex) public payable {
    require(_requestIndex < requests[msg.sender].length, "No Such Request");
    request[] storage myRequests = requests[msg.sender];
    request storage payableRequest = myRequests[_requestIndex];
        
    uint256 toPay = payableRequest.amountInWei;
    require(msg.value == toPay, "Pay Correct Amount");

    payable(payableRequest.requestor).transfer(msg.value);

    addHistory(msg.sender, payableRequest.requestor, payableRequest.amountInWei, payableRequest.message);

    myRequests[_requestIndex] = myRequests[myRequests.length - 1];
    myRequests.pop();
}

function addHistory(address sender, address receiver, uint256 _amountInWei, string memory _message) private {
    sendReceive memory newSend;
    newSend.action = "Send";
    newSend.amountInWei = _amountInWei; // amount in Wei
    newSend.message = _message;
    newSend.otherPartyAddress = receiver;
    if(names[receiver].hasName){
        newSend.otherPartyName = names[receiver].name;
    }
    history[sender].push(newSend);

    sendReceive memory newReceive;
    newReceive.action = "Receive";
    newReceive.amountInWei = _amountInWei; // amount in Wei
    newReceive.message = _message;
    newReceive.otherPartyAddress = sender;
    if(names[sender].hasName){
        newReceive.otherPartyName = names[sender].name;
    }
    history[receiver].push(newReceive);
}

// Get all requests sent to a User

function getMyRequests(address _user) public view returns (
         address[] memory, 
         uint256[] memory, 
         string[] memory, 
         string[] memory
) {
    address[] memory addrs = new address[](requests[_user].length);
    uint256[] memory amntInWei = new uint256[](requests[_user].length);
    string[] memory msge = new string[](requests[_user].length);
    string[] memory nme = new string[](requests[_user].length);
    
    for (uint i = 0; i < requests[_user].length; i++) {
        request storage myRequests = requests[_user][i];
        addrs[i] = myRequests.requestor;
        amntInWei[i] = myRequests.amountInWei;
        msge[i] = myRequests.message;
        nme[i] = myRequests.name;
    }
    
    return (addrs, amntInWei, msge, nme);        
}

// Get all historic transactions user has been a part of

function getMyHistory(address _user) public view returns (sendReceive[] memory) {
    return history[_user];
}

function getMyName(address _user) public view returns (userName memory) {
    return names[_user];
}
}
