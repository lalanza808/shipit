// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/sampleERC721.sol";
import "../src/sampleERC1155.sol";

contract MyScript is Script {
    function run() public {
        vm.broadcast();
    }
}