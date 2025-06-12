//SPDX-License-Identifier: MIT

pragma solidity >=0.8.18;


import {PriceConverter} from "./PriceConverter.sol";



error NotOwner ();

contract FundMe {
   
    using PriceConverter for uint256;

   uint256 public minmumUsd = 5e18;

   address[] public funders;

  mapping( address funder => uint256 amountFunded) public addressToAmountFunded;

   function fund () public payable {

    require(msg.value.getConversionRate() >= minmumUsd, "did not send enough eth");

    // msg.value.getConversionRate();
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
   }

   address public owner;

   constructor () {
    owner = msg.sender;
   }
   
   function withdraw () public onlyOwner {
    
    
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++) {
       address funder =funders[funderIndex];
       addressToAmountFunded[funder] = 0;
    }

    funders = new address[](0);

    //transfer
    //send
    // call

    // payable(msg.sender).transfer(address(this).balance);

    // //send 

    // bool sendSucess = payable(msg.sender).send(address(this).balance);
    // require(sendSucess, "send failed.");

    //call
 
    (bool callSucess, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(callSucess, "Call failed.");
   }

 modifier onlyOwner () {
    // require(msg.sender == owner, "only owner can call this function.");
    // _;

    if (msg.sender != owner) revert NotOwner();
    _;
 }

 receive() external payable {
    fund();
 }

 fallback() external payable { 
    fund();
 }
}