// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Test, console} from "forge-std/test.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumusdisfive() public view {
        assertEq(fundMe.MINMUM_USD(), 5e18);
    }
}
