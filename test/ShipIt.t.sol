// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ShipIt} from "../src/ShipIt.sol";
import {NFT721} from "../src/sampleERC721.sol";
import {NFT1155} from "../src/sampleERC1155.sol";

contract ShipItTest is Test {
    using stdStorage for StdStorage;
    ShipIt public shipit;
    NFT721 public nft721;
    NFT1155 public nft1155;

    function setUp() public {
        shipit = new ShipIt();
        nft721 = new NFT721();
        nft1155 = new NFT1155();
    }

    // Tokens

    function test721BulkTransferSuccess() public {
        uint256 amt = 20;
        uint256 fee = shipit.usageFee();
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
        nft721.setApprovalForAll(address(shipit), true);
        shipit.erc721BulkTransfer{value: val}(
            address(nft721),
            recipients,
            tokenIndexes
        );
        // assert balances
    }

    function testFail721NonTokenOwnerCanSend() public {
        uint256 amt = 1;
        uint256 fee = shipit.usageFee();
        uint256 val = fee * amt;
        uint256[] memory tokenIndexes = new uint256[](amt);
        address[] memory recipients = new address[](amt);
        tokenIndexes[0] = 1;
        recipients[0] = address(1);
        vm.deal(address(5), 1 ether);
        vm.deal(address(3), 1 ether);
        vm.startPrank(address(5));
        nft721.mint(amt);
        nft721.setApprovalForAll(address(shipit), true);
        vm.stopPrank();
        vm.prank(address(3));
        shipit.erc721BulkTransfer{value: val}(
            address(nft721),
            recipients,
            tokenIndexes
        );
    }

    function test1155BulkTransferSuccess() public {
        uint256 amt = 10;
        uint256 fee = shipit.usageFee();
        uint256 val = fee * amt;
        address[] memory recipients = new address[](2);
        uint256[] memory tokenIndexes = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        recipients[0] = address(11);
        recipients[1] = address(11);
        tokenIndexes[0] = 1;
        tokenIndexes[1] = 5;
        amounts[0] = amt;
        amounts[1] = amt;
        vm.deal(address(50), 1 ether);
        vm.startPrank(address(50));
        nft1155.mint(1, amt);
        nft1155.mint(5, amt);
        nft1155.setApprovalForAll(address(shipit), true);
        shipit.erc1155BulkTransfer{value: val}(
            address(nft1155),
            recipients,
            tokenIndexes,
            amounts
        );
        assertEq(nft1155.balanceOf(address(11), 1), 10);
        assertEq(nft1155.balanceOf(address(11), 5), 10);
    }

    function testFail1155NonTokenOwnerCanSend() public {
        uint256 amt = 1;
        uint256 fee = shipit.usageFee();
        uint256 val = fee * amt;
        address[] memory recipients = new address[](amt);
        uint256[] memory tokenIndexes = new uint256[](amt);
        uint256[] memory amounts = new uint256[](amt);
        tokenIndexes[0] = 1;
        recipients[0] = address(1);
        amounts[0] = amt;
        vm.deal(address(5), 1 ether);
        vm.deal(address(3), 1 ether);
        vm.startPrank(address(5));
        nft1155.mint(1, amt);
        nft1155.setApprovalForAll(address(shipit), true);
        vm.stopPrank();
        vm.prank(address(3));
        shipit.erc1155BulkTransfer{value: val}(
            address(nft1155),
            recipients,
            tokenIndexes,
            amounts
        );
    }

    // meta

    function testUpdateVault() public {
        vm.prank(address(1));
        shipit.updateVault(address(3));
        assertEq(shipit.addressVault(address(1)), address(3));
    }

    // admin

    function testOwnerCanWithdraw() public {
        address owner = shipit.owner();
        vm.deal(address(shipit), 1 ether);
        vm.deal(owner, 1 ether);
        vm.deal(address(20), 2 ether);
        vm.prank(owner);
        shipit.transferOwnership(address(20));
        vm.prank(address(20));
        shipit.withdraw();
        vm.startPrank(address(30));
        vm.expectRevert();
        shipit.withdraw();
    }

    function testOwnerCanUpdateFee() public {
        address owner = shipit.owner();
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        shipit.updateFee(0.1 ether);
        assertEq(shipit.usageFee(), 0.1 ether);
        vm.startPrank(address(1));
        vm.expectRevert();
        shipit.updateFee(0.25 ether);
    }

}
