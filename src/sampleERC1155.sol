// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {Counters} from "openzeppelin-contracts/utils/Counters.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract NFT1155 is ERC1155, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC1155("") {}

    function mint(uint256 id, uint256 amount) external {
        _mint(msg.sender, id, amount, "");
    }
}