//SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Test, console} from 'forge-std/Test.sol';

import {FundMe} from '../../src/FundMe.sol';

import {DeployFundMe} from '../../script/DeployFundMe.s.sol';

import {FundFundMe, WithdrawFundMe} from '../../script/interaction.s.sol';

contract testFundMeInteractions is Test {
  FundMe fundMe;

  address User = makeAddr('user');

  uint256 constant SEND_VALUE = 0.01 ether;

  uint256 constant STARTING_BALANCE = 10 ether;

  uint256 constant GAS_PRICE = 1;

  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(User, STARTING_BALANCE);
  }

  function testUserCanFundInteractions() public {
    FundFundMe fundFundMe = new FundFundMe();
    vm.prank(User);

    fundFundMe.fundFundMe{value: SEND_VALUE}(address(fundMe));
    assertEq(address(fundMe).balance, SEND_VALUE);

    // address funder = fundMe.getFunder(0);

    WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    withdrawFundMe.withdrawFundMe(address(fundMe));

    assertEq(address(fundMe).balance, 0);
  }
}
