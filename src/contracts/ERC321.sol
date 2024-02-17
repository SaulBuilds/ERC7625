// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../interfaces/IERC321Metadata.sol";
import "./templates/ERC20.sol";

/**
 * @title Smart Contract Marketplace for ERC321
 * @dev Implementation of an ERC321 contract to manage the creation and tracking of smart contracts with unique IDs.
 * @notice This contract enables the creation of new smart contract instances, tracks them with unique IDs, and associates metadata URIs with each.
 */
contract SmartContractMarketplace is IERC321Metadata, Ownable(msg.sender) {
    // Example ERC20 contract; replace with actual contract type if different
    ERC20Example private newContract;

    // Counter for the next unique contract ID
    uint256 private _nextContractId;

    // Mapping from contract ID to deployed contract instance address
    mapping(uint256 => address) private _contractInstances;

    // Mapping from contract ID to metadata URI
    mapping(uint256 => string) private _metadataURIs;

    /**
     * @dev Initializes the marketplace with the sender as the owner.
     */
    constructor() {
        _nextContractId = 0;
    }

    /**
     * @notice Creates a new smart contract instance and assigns a unique ID to it.
     * @dev Deploys a new instance of a smart contract and stores its address and metadata.
     * @param _metadata Encoded metadata associated with the new smart contract instance.
     * @return contractId The unique identifier for the newly created contract instance.
     */
    function createSmartContract(
        bytes calldata _metadata
    ) external returns (uint256 contractId) {
        contractId = _nextContractId++;
        newContract = new ERC20Example(); // Create a new contract instance; adjust the contract type as necessary
        _contractInstances[contractId] = address(newContract);
        _metadataURIs[contractId] = string(_metadata);
        emit ContractInstanceCreated(address(newContract), contractId);
    }

    /**
     * @notice Retrieves the metadata URI for a given contract ID.
     * @dev Returns the metadata URI associated with the contract ID.
     * @param contractId The unique identifier of the contract instance.
     * @return The metadata URI of the specified contract instance.
     */
    function tokenURI(
        uint256 contractId
    ) external view override returns (string memory) {
        return _metadataURIs[contractId];
    }

    /**
     * @notice Retrieves the address of the smart contract instance associated with a given contract ID.
     * @dev Returns the contract instance address for the specified contract ID.
     * @param contractId The unique identifier of the contract instance.
     * @return The address of the contract instance.
     */
    function instanceAddress(uint256 contractId) public view returns (address) {
        require(contractId < _nextContractId, "Instance does not exist: The specified contract ID is not valid.");
        return _contractInstances[contractId];
    }

    /**
     * @notice Creates a new smart contract instance with associated metadata.
     * @dev Similar to `createSmartContract` but included as part of the `IERC321Metadata` interface implementation.
     * @param _metadata Encoded metadata associated with the new smart contract instance.
     * @return contractId The unique identifier for the newly created contract instance.
     */
    function createInstance(bytes calldata _metadata) external override returns (uint256 contractId) {
        contractId = _nextContractId++;
        newContract = new ERC20Example(); // Adjust the contract type as necessary
        _contractInstances[contractId] = address(newContract);
        _metadataURIs[contractId] = string(_metadata);
        emit ContractInstanceCreated(address(newContract), contractId);
    }
}