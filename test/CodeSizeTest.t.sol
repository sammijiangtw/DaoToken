// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DaoToken.sol";

contract CodeSizeTest is Test {

    DaoToken daoToken;
	address public owner = address(1);

	function setUp() public {
		vm.startPrank(owner);
		daoToken = new DaoToken();
		vm.stopPrank();
  	}

    function testContractCodeSize() public{
		address contractAddr = address(daoToken);
		uint length = contractAddr.code.length;

		if(length > 0){
			console.log("contract length>0", length);
		} else {
			console.log("contract length==0", length);
		}
	}

	function testEOACodeSize() public{
		
		uint length = owner.code.length;

		assertEq(length , 0);
	}
}