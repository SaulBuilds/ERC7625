// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract DeploymentTracker {
    event NewDeploymentRegistered(address indexed contractAddress, address indexed metadataLibrary);

    mapping(address => address) public metadataLibraries;

    function registerContract(address contractAddress, address metadataLibrary) external {
        require(metadataLibraries[contractAddress] == address(0), "Contract already registered");
        
        metadataLibraries[contractAddress] = metadataLibrary;
        
        emit NewDeploymentRegistered(contractAddress, metadataLibrary);
    }
    function getMetadataLibrary(address contractAddress) external view returns (address) {
        require(metadataLibraries[contractAddress] != address(0), "Contract not registered");
        return metadataLibraries[contractAddress];
    }
}