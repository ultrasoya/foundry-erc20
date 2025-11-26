// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployer;
    OurToken public ourToken;

    address public BOB = makeAddr("bob");
    address public ALICE = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.prank(address(deployer));
        ourToken.transfer(BOB, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(BOB), STARTING_BALANCE);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(BOB);
        ourToken.approve(ALICE, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(ALICE);
        ourToken.transferFrom(BOB, ALICE, transferAmount);

        assertEq(ourToken.balanceOf(ALICE), transferAmount);
        assertEq(ourToken.balanceOf(BOB), STARTING_BALANCE - transferAmount);
    }
}
