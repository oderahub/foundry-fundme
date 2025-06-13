// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumusdisfive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMsgSender() public view {
        console.log("msg.sender", msg.sender);
        console.log("owner",fundMe.owner());
        assertEq(fundMe.owner(), address(this));
    }
}
