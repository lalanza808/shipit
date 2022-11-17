// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/utils/Strings.sol";

contract NFT is ERC721 {
    uint256 public currentTokenId;

    constructor() ERC721("NFT", "NFT") {}

    function mint(address r, uint256 mintAmount) external {
        for(uint256 i; i < mintAmount; i++) {
            currentTokenId += 1;
            _safeMint(r, currentTokenId);
        }
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return Strings.toString(id);
    }
}
