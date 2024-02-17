// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/Create2.sol";
import "../interfaces/IERC321Metadata.sol";
import "./templates/ERC721.sol";

/**
 * @title ERC321 Marketplace
 * @dev Implements ERC321 for the creation, management, and tokenization of smart contracts.
 * Enables the creation of contract instances using either direct deployment or CREATE2 for deterministic addresses.
 * Each instance is uniquely identified by a contractId, facilitating their management and interaction.
 */
contract ContractMarketplace is IERC321Metadata, Ownable {
    /// @notice Next available contract ID
    uint256 private _nextContractId;

    /// @notice Mapping from contract ID to its deployed instance address
    mapping(uint256 => address) private _contractInstances;

    /// @notice Mapping from contract ID to its metadata URI
    mapping(uint256 => string) private _metadataURIs;

    /**
     * @dev Sets the owner upon deployment and initializes contract IDs.
     */
    constructor() Ownable(msg.sender) {
        _nextContractId = 0;
    }

    /**
     * @notice Creates a new contract instance with metadata, using a unique salt for deterministic deployment.
     * @dev Uses the CREATE2 opcode for deploying contracts, allowing for predictable addresses.
     * @param _metadata The metadata associated with the new contract instance.
     * @param _salt A unique salt to determine the contract's address.
     * @return contractId The ID assigned to the newly created contract instance.
     */
    function createInstanceWithCreate2(
        bytes calldata _metadata, 
        bytes32 _salt
    ) 
        external 
        returns (uint256 contractId) 
    {
        require(_metadata.length > 0, "Invalid metadata: Metadata cannot be empty.");

        bytes memory bytecode = abi.encodePacked(type(ERC721Example).creationCode);
        address instance = Create2.deploy(0, _salt, bytecode);
        require(instance != address(0), "Deployment failed: Contract instance could not be deployed.");

        contractId = _nextContractId++;
        _contractInstances[contractId] = instance;
        _metadataURIs[contractId] = string(_metadata);

        emit ContractInstanceCreated(instance, contractId);
    }

    /**
     * @notice Retrieves the metadata URI for a specified contract ID.
     * @dev Returns the metadata URI associated with the given contract ID.
     * @param contractId The ID of the contract instance.
     * @return The metadata URI of the specified contract instance.
     */
    function tokenURI(uint256 contractId) external view override returns (string memory) {
        require(contractId < _nextContractId, "Query for nonexistent contract: This contract ID does not exist.");
        require(_contractInstances[contractId] != address(0), "Contract instance destroyed: The contract has been destroyed and is no longer available.");
        return _metadataURIs[contractId];
    }

    /**
     * @notice Retrieves the address of the contract instance associated with the given contract ID.
     * @dev Returns the contract instance address for the specified contract ID.
     * @param contractId The ID of the contract instance.
     * @return The address of the contract instance.
     */
    function instanceAddress(uint256 contractId) public view returns (address) {
        require(contractId < _nextContractId, "Query for nonexistent contract: This contract ID does not exist.");
        return _contractInstances[contractId];
    }

    /**
     * @notice Updates the metadata URI for a specified contract ID.
     * @dev Can only be called by the contract owner. Updates the metadata URI associated with a contract ID.
     * @param contractId The ID of the contract instance to update.
     * @param _newMetadataURI The new metadata URI to be associated with the contract ID.
     */
    function updateMetadataURI(
        uint256 contractId,
        string calldata _newMetadataURI
    ) external onlyOwner {
        require(contractId < _nextContractId, "Update for nonexistent contract: This contract ID does not exist.");
        _metadataURIs[contractId] = _newMetadataURI;
    }

    /**
     * @notice Destroys the contract instance associated with the given contract ID.
     * @dev Can only be called by the contract owner. Removes the contract instance and its metadata URI from the mappings.
     * @param contractId The ID of the contract instance to destroy.
     */
    function destroyContractInstance(uint256 contractId) external onlyOwner {
        require(contractId < _nextContractId, "Destruction of nonexistent contract: This contract ID does not exist.");
        delete _contractInstances[contractId];
        delete _metadataURIs[contractId];
    }

    /**
     * @notice Creates a new contract instance directly with associated metadata.
     * @dev Directly deploys a new contract instance and assigns it a unique contract ID.
     * @param _metadata The metadata associated with the new contract instance.
     * @return contractId The ID assigned to the newly created contract instance.
     */
    function createInstance(bytes calldata _metadata) external returns (uint256 contractId) {
        ERC721Example newContract = new ERC721Example(); // Assuming ERC721Example's constructor does not require parameters
        address newContractAddress = address(newContract);

        contractId = _nextContractId++;
        _contractInstances[contractId] = newContractAddress;
        _metadataURIs[contractId] = string(_metadata);

        emit ContractInstanceCreated(newContractAddress, contractId);
    }
}