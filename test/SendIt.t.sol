// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SendIt.sol";

contract SendItTest is Test {
    SendIt public sendit;

    function setUp() public {
        sendit = new SendIt();
    }

    function testUpdateVault() public {
        sendit.updateVault(address(3));
        assertEq(sendit.addressVault(address(0)), address(3));
    }
}
