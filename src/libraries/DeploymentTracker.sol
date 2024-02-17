// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract DeploymentTracker {
    // Event to be emitted upon new contract/library deployment registration
    event NewDeploymentRegistered(address indexed contractAddress, address indexed metadataLibrary);

    // Mapping from contract address (or unique identifier) to its metadata library address
    mapping(address => address) public metadataLibraries;

    // Function to register a new contract and its metadata library
    function registerContract(address contractAddress, address metadataLibrary) external {
        require(metadataLibraries[contractAddress] == address(0), "Contract already registered");
        
        // Register the metadata library for the contract
        metadataLibraries[contractAddress] = metadataLibrary;
        
        // Emit an event with the contract and metadata library addresses
        emit NewDeploymentRegistered(contractAddress, metadataLibrary);
    }

    // Function to retrieve the address of a contract's metadata library
    function getMetadataLibrary(address contractAddress) external view returns (address) {
        require(metadataLibraries[contractAddress] != address(0), "Contract not registered");
        return metadataLibraries[contractAddress];
    }
}