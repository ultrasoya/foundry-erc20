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

    // Событие для тестирования Transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(BOB, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(BOB), STARTING_BALANCE);
    }

    function testAllowances() public {
        uint256 initialAllowance = 100;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(BOB);
        ourToken.approve(ALICE, initialAllowance);

        uint256 transferAmount = 50;

        vm.prank(ALICE);
        ourToken.transferFrom(BOB, ALICE, transferAmount);

        assertEq(ourToken.balanceOf(ALICE), transferAmount);
        assertEq(ourToken.balanceOf(BOB), STARTING_BALANCE - transferAmount);
    }

    function testInitialSupplyAssignedToDeployer() public view {
        // В скрипте деплоя вся initial supply у адреса, который деплоил (msg.sender при создании контракта)
        uint256 totalSupply = ourToken.totalSupply();
        assertEq(
            ourToken.balanceOf(msg.sender),
            totalSupply - STARTING_BALANCE
        );
    }

    function testTransferUpdatesBalances() public {
        uint256 transferAmount = 10 ether;

        vm.prank(BOB);
        ourToken.transfer(ALICE, transferAmount);

        assertEq(ourToken.balanceOf(BOB), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(ALICE), transferAmount);
    }

    function testTransferEmitsEvent() public {
        uint256 transferAmount = 1 ether;

        vm.prank(BOB);
        vm.expectEmit(true, true, false, true);
        emit Transfer(BOB, ALICE, transferAmount);
        ourToken.transfer(ALICE, transferAmount);
    }

    function testTransferFailsWhenInsufficientBalance() public {
        uint256 bigAmount = STARTING_BALANCE + 1;

        vm.prank(BOB);
        vm.expectRevert();
        ourToken.transfer(ALICE, bigAmount);
    }

    function testApproveSetsAllowance() public {
        uint256 allowanceAmount = 123;

        vm.prank(BOB);
        ourToken.approve(ALICE, allowanceAmount);

        assertEq(ourToken.allowance(BOB, ALICE), allowanceAmount);
    }

    function testTransferFromSpendsAllowance() public {
        uint256 initialAllowance = 100;
        uint256 transferAmount = 60;

        vm.prank(BOB);
        ourToken.approve(ALICE, initialAllowance);

        vm.prank(ALICE);
        ourToken.transferFrom(BOB, ALICE, transferAmount);

        assertEq(
            ourToken.allowance(BOB, ALICE),
            initialAllowance - transferAmount
        );
        assertEq(ourToken.balanceOf(ALICE), transferAmount);
        assertEq(ourToken.balanceOf(BOB), STARTING_BALANCE - transferAmount);
    }

    function testTransferFromFailsWhenInsufficientAllowance() public {
        uint256 initialAllowance = 10;
        uint256 transferAmount = 20;

        vm.prank(BOB);
        ourToken.approve(ALICE, initialAllowance);

        vm.prank(ALICE);
        vm.expectRevert();
        ourToken.transferFrom(BOB, ALICE, transferAmount);
    }

    function testTransferFromFailsWhenInsufficientBalance() public {
        uint256 initialAllowance = 1000 ether;
        uint256 transferAmount = STARTING_BALANCE + 1 ether;

        vm.prank(BOB);
        ourToken.approve(ALICE, initialAllowance);

        vm.prank(ALICE);
        vm.expectRevert();
        ourToken.transferFrom(BOB, ALICE, transferAmount);
    }

    function testTotalSupplyConstantAfterTransfers() public {
        uint256 initialSupply = ourToken.totalSupply();

        vm.prank(BOB);
        ourToken.transfer(ALICE, 10 ether);

        vm.prank(ALICE);
        ourToken.transfer(BOB, 5 ether);

        assertEq(ourToken.totalSupply(), initialSupply);
    }

    function testDecimalsIs18() public view {
        assertEq(ourToken.decimals(), 18);
    }

    function testNameAndSymbol() public view {
        assertEq(ourToken.name(), "OurToken");
        assertEq(ourToken.symbol(), "OT");
    }
}
