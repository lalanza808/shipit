#!/bin/bash

source .env

ERC721=0x5FbDB2315678afecb367f032d93F642f64180aa3
ERC1155=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
SHIPIT=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
OP=0x653D2d1D10c79017b2eA5F5a6F02D9Ab6e725395

echo -e "[+] Deploying ERC-721"
forge create --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY src/sampleERC721.sol:NFT721 | grep Deployed

echo -e "[+] Deploying ERC-1155"
forge create --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY src/sampleERC1155.sol:NFT1155 | grep Deployed

echo -e "[+] Deploying ShipIt"
forge create --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY src/ShipIt.sol:ShipIt | grep Deployed

echo -e "[+] Sending test Ether"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $OP --value 0.5ether > /dev/null

echo -e "[+] Minting 800 ERC-721 tokens to deployer (id 1-800)"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $ERC721 "mint(uint256)" 800 > /dev/null

echo -e "[+] Minting 800 ERC-1155 tokens to deployer (id 1)"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $ERC1155 "mint(uint256,uint256)" 1 800 > /dev/null

echo -e "[+] Minting 800 ERC-1155 tokens to deployer (id 2)"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $ERC1155 "mint(uint256,uint256)" 2 800 > /dev/null

echo -e "[+] Minting 800 ERC-1155 tokens to deployer (id 3)"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $ERC1155 "mint(uint256,uint256)" 3 800 > /dev/null

echo -e "[+] Setting approval for contracts"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $ERC721 "setApprovalForAll(address,bool)"  $SHIPIT true > /dev/null
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY $ERC1155 "setApprovalForAll(address,bool)"  $SHIPIT true > /dev/null
