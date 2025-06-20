// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;

    uint256 STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testMinimumusdisfive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMsgSender() public view {
        // console.log("msg.sender", msg.sender);
        // console.log("owner", fundMe.owner());
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testFundMeUpdatesDataStructureWhenFunded() public funded {
        uint256 amountFunded = fundMe.getAddressToAmoutFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddfunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawalWithSingleFunder() public {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeContractBalance = address(fundMe).balance;

        //Act

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeContractBalance = address(fundMe).balance;
        assertEq(endingFundMeContractBalance, 0);

        assertEq(startingFundMeContractBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawalFromMultipleFunders() public {
        uint160 numberOffunders = 20;
        uint160 startingIndex = 1;

        for (uint160 index = startingIndex; index < numberOffunders; index++) {
            //we have to create all these address
            // fund them

            hoax(address(index), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        //Act

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        uint256 endingContractBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingContractBalance, 0);
        assertEq(startingOwnerBalance + startingContractBalance, endingOwnerBalance);
    }
}
