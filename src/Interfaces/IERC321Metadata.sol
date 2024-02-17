// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC321 {
    event ContractInstanceCreated(address indexed instance, uint256 indexed tokenId);
    function createInstance(bytes calldata _metadata) external returns (uint256);
}
interface IERC321Metadata is IERC321 {
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}
