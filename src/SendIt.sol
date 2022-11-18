// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract SendIt is Ownable {

    mapping(address => address) public addressVault; // users can store their personal vaults for ease of use
    uint256 public usageFee = .0001 ether;           // charge a small fee for the cost savings it provides

    event TokenTransfer(address indexed contractAddress, uint256 tokenIndex, address indexed from, address indexed to);
    
    /*************************
    Modifiers
    **************************/

    modifier onlyIfTokenOwner(
        address contractAddress,
        uint256 tokenIndex,
        bool isERC1155
    ) {
        if (isERC1155) {
            require(ERC1155(contractAddress).balanceOf(msg.sender, tokenIndex) > 0, "You must own the token.");
        } else {
            require(msg.sender == ERC721(contractAddress).ownerOf(tokenIndex), "You must own the token.");
        }
        _;
    }

    /*************************
    Admin
    **************************/

    function updateFee(uint256 amount) external onlyOwner {
        usageFee = amount;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /*************************
    User
    **************************/

    function updateVault(address vaultAddress) external {
        addressVault[msg.sender] = vaultAddress;
    }

    function contractTransfer(
        address contractAddress,
        uint256 tokenIndex,
        address recipient,
        bool isERC1155
    ) private {
        if (isERC1155) {
            require(ERC1155(contractAddress).balanceOf(msg.sender, tokenIndex) > 0, "Sender is not the token owner, cannot proceed with transfer.");
            require(ERC1155(contractAddress).isApprovedForAll(msg.sender, address(this)), "Contract not approved to send tokens on Sender behalf.");
            ERC1155(contractAddress).safeTransferFrom(msg.sender, recipient, tokenIndex, 1, bytes(""));
        } else {
            require(msg.sender == ERC721(contractAddress).ownerOf(tokenIndex), "Sender is not the token owner, cannot proceed with transfer.");
            require(ERC721(contractAddress).isApprovedForAll(msg.sender, address(this)), "Contract not approved to send tokens on Sender behalf.");
            ERC721(contractAddress).safeTransferFrom(msg.sender, recipient, tokenIndex);
        }
        emit TokenTransfer(contractAddress, tokenIndex, msg.sender, recipient);
    }

    function contractBulkTransfer(
        address contractAddress,
        uint256[] calldata tokenIndexes,
        address[] calldata recipients,
        bool isERC1155
    ) external payable {
        require(tokenIndexes.length == recipients.length, "Array lengths must match.");
        require(msg.value >= tokenIndexes.length * usageFee, "Invalid usage fee sent.");
        for(uint256 i; i < tokenIndexes.length; i++) {
            contractTransfer(contractAddress, tokenIndexes[i], recipients[i], isERC1155);
        }
    }

}
