// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title Immutable Metadata Registry
 * @dev Manages immutable associations between deployed contracts and their metadata stored as JSON files on-chain.
 * This contract enables the permanent, one-time registration of metadata for any deployed contract,
 * leveraging the benefits of blockchain's immutability to ensure that once metadata is stored, it is available forever without additional costs.
 * Ideal for storing contract metadata, such as descriptions, attributes, or URIs, in a cost-effective and unalterable format.
 */
contract ImmutableMetadataRegistry {
    /**
     * @dev Emitted when new contract metadata is registered.
     * @param contractAddress Address of the registered contract.
     * @param metadataLocation Address pointing to the on-chain JSON metadata blob.
     */
    event MetadataRegistered(address indexed contractAddress, address indexed metadataLocation);

    /// @notice Mapping from contract addresses to their immutable JSON metadata location.
    mapping(address => address) public immutableMetadataLocations;

    /**
     * @notice Registers metadata for a deployed contract by linking it to an immutable JSON file on-chain.
     * @dev Stores the association between a contract and its metadata permanently on the blockchain.
     * This method incurs a one-time gas cost, after which the metadata is available forever without further blockchain fees.
     * @param contractAddress Address of the deployed contract to associate metadata with.
     * @param metadataLocation Address of the on-chain JSON metadata blob.
     */
    function registerMetadata(address contractAddress, address metadataLocation) external {
        require(immutableMetadataLocations[contractAddress] == address(0), "Metadata already registered for contract");
        
        immutableMetadataLocations[contractAddress] = metadataLocation;
        
        emit MetadataRegistered(contractAddress, metadataLocation);
    }

    /**
     * @notice Retrieves the on-chain JSON metadata location for a registered contract.
     * @dev Returns the address of the immutable JSON file associated with the given contract address.
     * Allows for permanent, cost-free access to contract metadata after the initial registration.
     * @param contractAddress Address of the deployed contract whose metadata is being queried.
     * @return The address of the on-chain JSON metadata blob associated with the contract.
     */
    function getMetadataLocation(address contractAddress) external view returns (address) {
        require(immutableMetadataLocations[contractAddress] != address(0), "No metadata registered for contract");
        return immutableMetadataLocations[contractAddress];
    }
}