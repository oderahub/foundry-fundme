//SPDX-License-Identifier: MIT

pragma solidity >=0.8.18;

import {PriceConverter} from './PriceConverter.sol';
import {AggregatorV3Interface} from '@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol';

error FundMe__NotOwner();

contract FundMe {
  using PriceConverter for uint256;

  uint256 public constant MINIMUM_USD = 5e18;

  address public immutable i_owner;

  AggregatorV3Interface private s_priceFeed;

  constructor(address priceFeed) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeed);
  }

  address[] private s_funders;

  mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

  function fund() public payable {
    require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, 'did not send enough eth');

    // msg.value.getConversionRate();
    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] += msg.value;
  }

  function withdraw() public onlyOwner {
    for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }

    s_funders = new address[](0);

    //transfer
    //send
    // call

    // payable(msg.sender).transfer(address(this).balance);

    // //send

    // bool sendSucess = payable(msg.sender).send(address(this).balance);
    // require(sendSucess, "send failed.");

    //call

    (bool callSucess, ) = payable(msg.sender).call{value: address(this).balance}('');
    require(callSucess, 'Call failed.');
  }

  modifier onlyOwner() {
    // require(msg.sender == owner, "only owner can call this function.");
    // _;

    if (msg.sender != i_owner) revert FundMe__NotOwner();
    _;
  }

  function getVersion() public view returns (uint256) {
    return s_priceFeed.version();
  }

  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }

  function getAddressToAmoutFunded(address fundingAddress) external view returns (uint256) {
    return s_addressToAmountFunded[fundingAddress];
  }

  function getFunder(uint256 index) external view returns (address) {
    return s_funders[index];
  }
}
