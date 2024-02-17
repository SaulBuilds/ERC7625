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

/**
 * @title IERC321Metadata Interface Extension
 * @dev Extension of the IERC321 interface to support metadata operations.
 */
interface IERC321Metadata is IERC321 {
    /**
     * @notice Retrieves the metadata URI for a given contract ID.
     * @param contractId The unique identifier of the tokenized smart contract instance.
     * @return The URI of the metadata associated with the specified contract instance.
     */
    function tokenURI(uint256 contractId) external view returns (string memory);
}