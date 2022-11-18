// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SendIt} from "../src/SendIt.sol";
import {NFT721} from "../src/sampleERC721.sol";
import {NFT1155} from "../src/sampleERC1155.sol";

contract SendItTest is Test {
    using stdStorage for StdStorage;
    SendIt public sendit;
    NFT721 public nft721;
    NFT1155 public nft1155;

    function setUp() public {
        sendit = new SendIt();
        nft721 = new NFT721();
        nft1155 = new NFT1155();
    }

    // Tokens

    function test721BulkTransferSuccess() public {
        uint256 amt = 20;
        uint256 fee = sendit.usageFee();
        uint256 val = fee * amt;
        uint256[] memory tokenIndexes = new uint256[](amt);
        address[] memory recipients = new address[](amt);
        for (uint256 i; i < amt; i++) {
            tokenIndexes[i] = i + 1;
            recipients[i] = address(1);
        }
        vm.deal(address(5), 1 ether);
        vm.startPrank(address(5));
        nft721.mint(amt);
        nft721.setApprovalForAll(address(sendit), true);
        sendit.contractBulkTransfer{value: val}(
            address(nft721),
            tokenIndexes,
            recipients,
            false
        );
        // assert balances
    }

    function testFail721NonTokenOwnerCanSend() public {
        uint256 amt = 1;
        uint256 fee = sendit.usageFee();
        uint256 val = fee * amt;
        uint256[] memory tokenIndexes = new uint256[](amt);
        address[] memory recipients = new address[](amt);
        tokenIndexes[0] = 1;
        recipients[0] = address(1);
        vm.deal(address(5), 1 ether);
        vm.deal(address(3), 1 ether);
        vm.startPrank(address(5));
        nft721.mint(amt);
        nft721.setApprovalForAll(address(sendit), true);
        vm.stopPrank();
        vm.prank(address(3));
        sendit.contractBulkTransfer{value: val}(
            address(nft721),
            tokenIndexes,
            recipients,
            false
        );
    }

    function test1155BulkTransferSuccess() public {
        uint256 amt = 10;
        uint256 fee = sendit.usageFee();
        uint256 val = fee * amt;
        uint256[] memory tokenIndexes = new uint256[](amt);
        address[] memory recipients = new address[](amt);
        for (uint256 i; i < amt; i++) {
            tokenIndexes[i] = 1;
            recipients[i] = address(1);
        }
        vm.deal(address(5), 1 ether);
        vm.startPrank(address(5));
        nft1155.mint(1, amt);
        nft1155.setApprovalForAll(address(sendit), true);
        sendit.contractBulkTransfer{value: val}(
            address(nft1155),
            tokenIndexes,
            recipients,
            true
        );
        assertEq(nft1155.balanceOf(address(1), 1), 10);
    }

    function testFail1155NonTokenOwnerCanSend() public {
        uint256 amt = 1;
        uint256 fee = sendit.usageFee();
        uint256 val = fee * amt;
        uint256[] memory tokenIndexes = new uint256[](amt);
        address[] memory recipients = new address[](amt);
        tokenIndexes[0] = 1;
        recipients[0] = address(1);
        vm.deal(address(5), 1 ether);
        vm.deal(address(3), 1 ether);
        vm.startPrank(address(5));
        nft1155.mint(1, amt);
        nft1155.setApprovalForAll(address(sendit), true);
        vm.stopPrank();
        vm.prank(address(3));
        sendit.contractBulkTransfer{value: val}(
            address(nft1155),
            tokenIndexes,
            recipients,
            true
        );
    }

    // meta

    function testUpdateVault() public {
        vm.prank(address(1));
        sendit.updateVault(address(3));
        assertEq(sendit.addressVault(address(1)), address(3));
    }

    // admin

    function testOwnerCanWithdraw() public {
        address owner = sendit.owner();
        vm.deal(address(sendit), 1 ether);
        vm.deal(owner, 1 ether);
        vm.deal(address(20), 2 ether);
        vm.prank(owner);
        sendit.transferOwnership(address(20));
        vm.prank(address(20));
        sendit.withdraw();
        vm.startPrank(address(30));
        vm.expectRevert();
        sendit.withdraw();
    }

    function testOwnerCanUpdateFee() public {
        address owner = sendit.owner();
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        sendit.updateFee(0.1 ether);
        assertEq(sendit.usageFee(), 0.1 ether);
        vm.startPrank(address(1));
        vm.expectRevert();
        sendit.updateFee(0.25 ether);
    }

}
