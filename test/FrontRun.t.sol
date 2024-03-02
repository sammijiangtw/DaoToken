// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/DaoToken.sol";

contract FrontRunTest is Test {
    DaoToken daoToken;
	address public owner = address(0);
	address public hacker =address(1337);

	address public alice= address(1);
	address public bob = address(2);
	address public bobAnotherAcct = address(3);

	function setUp() public {
		vm.startPrank(owner);
		daoToken = new DaoToken();
		daoToken.mint(alice, 1000);
		vm.stopPrank();
  }
	
	function testFrontRun() public {
        
        vm.prank(alice);
		daoToken.approve(bob, 100);
		
		vm.prank(bob);
		daoToken.transferFrom(alice, bobAnotherAcct, 100);

		vm.prank(alice);
		daoToken.approve(bob, 50);

		vm.prank(bob);
		uint256 allowanceMoney = daoToken.allowance(alice, bob);
		uint256 balance = daoToken.balanceOf(bobAnotherAcct);
		assertEq(allowanceMoney , 50);
		assertEq(balance, 100);
    }
}