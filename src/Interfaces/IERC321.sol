// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title IERC321 Smart Contract Tokenization Interface
 * @dev Interface for the tokenization and management of smart contracts, facilitating their identification, and enabling interactions like creation and metadata management.
 */
interface IERC321 {
    /**
     * @dev Emitted when a new smart contract instance is created and tokenized.
     * @param instance Address of the created smart contract instance.
     * @param contractId Unique identifier for the tokenized contract instance.
     */
    event ContractInstanceCreated(address indexed instance, uint256 indexed contractId);

    /**
     * @notice Creates a new tokenized smart contract instance with associated metadata.
     * @param _metadata Encoded metadata associated with the smart contract instance.
     * @return contractId The unique identifier assigned to the created smart contract instance.
     */
    function createInstance(bytes calldata _metadata) external returns (uint256 contractId);
}