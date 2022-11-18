#!/bin/bash

source .env

echo -e "[+] Deploying ERC-721"
forge create --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY src/sampleERC721.sol:NFT721 | grep Deployed

echo -e "\n[+] Deploying ERC-1155"
forge create --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY src/sampleERC1155.sol:NFT1155 | grep Deployed

echo -e "\n[+] Deploying SendIt"
forge create --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY src/SendIt.sol:SendIt | grep Deployed

echo -e "\n[+] Sending test Ether"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY 0x653D2d1D10c79017b2eA5F5a6F02D9Ab6e725395 --value 0.5ether

echo -e "[+] Minting 500 ERC-721 tokens to deployer"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY 0x5FbDB2315678afecb367f032d93F642f64180aa3 "mint(uint256)" 500 | grep -v logs

echo -e "[+] Minting 500 ERC-1155 tokens to deployer"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "mint(uint256,uint256)" 1 500 | grep -v logs

echo -e "[+] Setting approval for contract"
cast send --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY 0x5FbDB2315678afecb367f032d93F642f64180aa3 "setApprovalForAll(address,bool)"  0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 true | grep -v logs

