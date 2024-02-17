
**eip:321 Smart Contract ID & Marketplace Standard**  
A standard for applying contractId's to SmartContracts, enabling ease in transferring smart contract ownership in marketplaces.
**authors:** Larry Klosowski @QuFoamLabs (larryklosowski@proton.me) 
**discussions-to:** n/a
**status:** Draft
**type:** Standards
**category: ERC  
**created:** 02/02/2024
**requires:** 321

### Abstract
ERC-321 introduces a protocol for the tokenization of smart contracts, enabling their identification, management, and integration into marketplaces. This standard provides a systematic approach to creating contract instances with unique identifiers, managing ownership, and handling metadata. It aims to support the sale, purchase, and collection of smart contracts, facilitating their use as assets with defined ownership and characteristics.

### Motivation
The advancement of blockchain technology and the proliferation of decentralized applications (dApps) highlight the necessity for a protocol that can manage smart contracts more dynamically and interoperably. There exists a notable requirement for a standardized mechanism that supports the tokenization, exchange, and aggregation of smart contracts. ERC-321, along with the ERC-321Metadata extension, is designed to meet this need by offering a structured interface for smart contract lifecycle management within marketplaces. This enables the effective packaging and monetization of smart contracts, addressing the growing market for smart contract acquisition and legal trade.

### Specification
**ERC-321 Interface:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title IERC321 Smart Contract Tokenization Interface
 * @dev Interface for tokenization and management of smart contracts, facilitating identification and enabling interactions like creation and metadata management.
 */
interface IERC321 {
    event ContractInstanceCreated(address indexed instance, uint256 indexed contractId);
    function createInstance(bytes calldata _metadata) external returns (uint256 contractId);
}
```

**ERC-321Metadata Extension:**
```solidity
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
```

### Rationale
The ERC-321 standard addresses the need for a systematic approach to smart contract tokenization, enabling the safe sale and transfer of smart contracts on marketplaces. It lays the foundation for an acquisitions market and a legal framework for smart contract sales and trade, by providing the necessary infrastructure for assigning unique identifiers to contract instances, managing ownership, and associating metadata. This standard simplifies the integration of contracts into existing and future dApps and platforms, promoting a structured marketplace where contracts can be efficiently traded and managed.
### Reference Implementation


**Example Implementation:**
```solidity
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
```

### Security Considerations
Ensuring the secure implementation of ERC-321 is crucial, with a particular emphasis on managing contract ownership and safeguarding metadata integrity. Following best practices in smart contract security and opting for decentralized storage solutions for metadata are essential steps to mitigate risks and prevent central points of failure.

### Backwards Compatibility
Designed with backward compatibility in mind, ERC-321 ensures a seamless interaction with existing ERC standards and the Ethereum ecosystem at large. This facilitates the standard's adoption, enabling its practical implementation in current systems and technologies.

### Copyright
Copyright and related rights waived via CC0.

### Author
Larry Klosowski @QuFoamLabs https://github.com/saulBuilds
