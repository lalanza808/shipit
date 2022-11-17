// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SendIt} from "../src/SendIt.sol";
import {NFT} from "../src/NFT.sol";

contract SendItTest is Test {
    using stdStorage for StdStorage;
    SendIt public sendit;
    NFT public nft;

    function setUp() public {
        sendit = new SendIt();
        nft = new NFT();
    }

    function testBulkTransferSucceeds() public {
        uint256 amt = 20;
        uint256[] memory tokenIndexes = new uint256[](amt);
        address[] memory recipients = new address[](amt);
        for (uint256 i; i < amt; i++) {
            tokenIndexes[i] = i + 1;
            recipients[i] = address(1);
        }
        vm.startPrank(address(5));
        nft.mint(address(5), amt);
        nft.setApprovalForAll(address(sendit), true);
        sendit.contractBulkTransfer(
            address(nft),
            tokenIndexes,
            recipients,
            false
        );
        vm.stopPrank();
    }

    function testSingleTransfer() public {
        nft.mint(address(5), 20);
        vm.startPrank(address(5));
        for (uint256 i; i < 20; i++) {
            nft.safeTransferFrom(address(5), address(1), i + 1);
        }
        vm.stopPrank();
    }

    // function testUpdateVault() public {
    //     sendit.updateVault(address(3));
    //     console.log(address(sendit));
    //     // console.log(sendit);
    //     assertEq(sendit.addressVault(address(2)), address(0));
    // }
}
