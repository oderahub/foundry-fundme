// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Test, console} from 'forge-std/Test.sol';

import {FundMe} from '../src/FundMe.sol';

import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
  FundMe fundMe;

  address USER = makeAddr('user');

  uint256 constant SEND_VALUE = 0.1 ether;

  uint256 STARTING_BALANCE = 10 ether;

  function setUp() external {
    // fundMe = new FundMe(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(USER, STARTING_BALANCE);
  }

  function testMinimumusdisfive() public view {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwnerisMsgSender() public view {
    // console.log("msg.sender", msg.sender);
    // console.log("owner", fundMe.owner());
    assertEq(fundMe.i_owner(), msg.sender);
  }

  function testPriceFeedVersionIsAccurate() public view {
    if (block.chainid == 11155111) {
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
    } else if (block.chainid == 1) {
      uint256 version = fundMe.getVersion();
      assertEq(version, 6);
    }
  }

  function testFundMeFailWithoutEnoughEth() public {
    vm.expectRevert();
    fundMe.fund{value: 4e10}();
  }

  function testFundMeUpdatesDataStructureWhenFunded() public {
    vm.prank(USER);
    fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmoutFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }
}
