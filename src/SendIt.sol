// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/tokens/ERC1155.sol";

contract SendIt {

    mapping(address => address) public addressVault;

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

    function updateVault(address vaultAddress) external {
        addressVault[msg.sender] = vaultAddress;
    }

    function contractTransfer(
        address contractAddress,
        uint256 tokenIndex,
        address recipient,
        bool isERC1155
    ) public {
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
    ) external {
        require(tokenIndexes.length == recipients.length, "Array lengths must match.");
        for(uint256 i; i < tokenIndexes.length; i++) {
            contractTransfer(contractAddress, tokenIndexes[i], recipients[i], isERC1155);
        }
    }

}
