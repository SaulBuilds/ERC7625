// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/ERC321Create2.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Contract Marketplace Test Suite
 * @notice This suite conducts various tests on the ContractMarketplace to ensure its functionalities work as expected.
 * It includes tests for creating instances with unique salts, updating metadata URIs, and handling access control.
 */
contract ContractMarketplaceTest is Test, Ownable {
    ContractMarketplace public marketplace;
    // Unique salts for creating contract instances
    bytes32 public salt = keccak256("UNIQUE_SALT");
    bytes32 public salt2 = keccak256("ANOTHER_UNIQUE_SALT");
    // Sample metadata for testing
    bytes public metadata = bytes("Metadata URI");
    bytes public metadata2 = bytes("Another Metadata URI");

    /**
     * @dev Sets up the contract owner and initializes the marketplace contract for testing.
     */
    constructor() Test() Ownable(msg.sender) {}

    /**
     * @dev Prepares the marketplace contract before each test.
     */
    function setUp() public {
        marketplace = new ContractMarketplace();
    }

    /**
     * @notice Tests the ability to create a contract instance using CREATE2, ensuring unique instance creation.
     */
    function testCreateInstanceWithCreate2() public {
        // Implementation details to follow, focusing on creating an instance with CREATE2 and verifying its creation.
    }

    /**
     * @notice Tests that creating contract instances with the same salt fails to prevent duplicate entries.
     * @dev Expects the transaction to revert due to salt uniqueness constraints.
     */
    function testFailCreateInstanceWithSameSalt() public {
        marketplace.createInstanceWithCreate2(metadata, salt);
        vm.expectRevert("Salt already used");
        marketplace.createInstanceWithCreate2(metadata2, salt);
    }

    /**
     * @notice Verifies the sequential assignment of contract IDs and correct metadata URI mapping for multiple instances.
     * @dev Creates two instances with different salts and checks if their IDs and metadata URIs are correctly assigned.
     */
    function testCreateMultipleInstances() public {
        uint256 contractId1 = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );
        uint256 contractId2 = marketplace.createInstanceWithCreate2(
            metadata2,
            salt2
        );

        assertEq(
            contractId1 + 1,
            contractId2,
            "Contract IDs should be sequential."
        );
        assertEq(
            marketplace.tokenURI(contractId1),
            string(metadata),
            "First contract URI should match."
        );
        assertEq(
            marketplace.tokenURI(contractId2),
            string(metadata2),
            "Second contract URI should match."
        );
    }

    /**
     * @notice Ensures that querying the token URI for an unregistered contract ID results in a revert.
     * @dev Attempts to fetch the token URI for a nonexistent contract ID, expecting a revert due to registration requirement.
     */
    function testTokenURIForNonexistentToken() public {
        uint256 nonExistentContractId = 999;
        vm.expectRevert("Contract not registered");
        marketplace.tokenURI(nonExistentContractId);
    }

    /**
     * @notice Tests creating a contract instance without using CREATE2 and verifies correct ID assignment and metadata association.
     * @dev Directly creates a contract instance and checks its ID and metadata URI.
     */
    function testCreateInstanceWithoutCreate2() public {
        uint256 contractId = marketplace.createInstance(metadata);

        assertEq(
            contractId,
            0,
            "Contract ID should be 0 for the first contract instance created without CREATE2."
        );
        assertEq(
            marketplace.tokenURI(contractId),
            string(metadata),
            "Metadata URI should match for the created instance."
        );
    }

    /**
     * @notice Verifies that the correct instance address is returned for a given contract ID.
     * @dev Creates a contract instance and then fetches its address using the instance's ID.
     */
    function testInstanceAddress() public {
        uint256 contractId = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );
        address instanceAddress = marketplace.instanceAddress(contractId);

        assertTrue(
            instanceAddress != address(0),
            "The contract instance address should not be the zero address."
        );
    }

    /**
     * @notice Tests updating the metadata URI for an existing contract instance and verifies the update is successful.
     * @dev Updates the metadata URI for a contract instance and checks the new URI is correctly stored.
     */
    function testSuccessfulUpdateMetadataURI() public {
        uint256 contractId = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );

        string memory newMetadataURI = "Updated Metadata URI";
        marketplace.updateMetadataURI(contractId, newMetadataURI);

        string memory updatedURI = marketplace.tokenURI(contractId);
        assertEq(
            updatedURI,
            newMetadataURI,
            "The metadata URI should be successfully updated."
        );
    }

    /**
     * @notice Ensures that an unauthorized address cannot update the metadata URI of a contract instance.
     * @dev Attempts to update the metadata URI from an unauthorized address, expecting the call to fail.
     */
    function testUnauthorizedUpdateMetadataURI() public {
        uint256 contractId = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );
        address unauthorizedAddress = address(0xdeadbeef);
        vm.prank(unauthorizedAddress);

        vm.expectRevert("Ownable: caller is not the owner");
        marketplace.updateMetadataURI(
            contractId,
            "Unauthorized Update Metadata URI"
        );
    }

    /**
     * @notice Tests that updating the metadata URI by non-owner addresses is prohibited.
     * @dev Simulates a metadata URI update attempt by an unauthorized (non-owner) address and checks for access control enforcement.
     */
    function testFailToUpdateMetadataURINonOwner() public {
        uint256 contractId = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );
        vm.prank(address(0xdead)); // Simulate call from unauthorized address
        vm.expectRevert("Ownable: caller is not the owner");
        marketplace.updateMetadataURI(contractId, "Unauthorized Metadata URI");
    }

    /**
     * @notice Tests the contract's handling of attempts to destroy a contract instance.
     * @dev Creates and then destroys a contract instance, verifying that subsequent actions on the instance are correctly prohibited.
     */
    function testContractDestruction() public {
        uint256 contractId = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );
        marketplace.destroyContractInstance(contractId);

        vm.expectRevert("Contract has been destroyed");
        marketplace.tokenURI(contractId);
    }

    /**
     * @notice Verifies that querying the address of an unregistered (or destroyed) contract instance results in a revert.
     * @dev Attempts to fetch the instance address for a non-existent contract ID, expecting a revert due to the instance not being registered.
     */
    function testNonexistentInstanceAddress() public {
        uint256 nonExistentContractId = 999;
        vm.expectRevert("Instance does not exist");
        marketplace.instanceAddress(nonExistentContractId);
    }

    /**
     * @notice Tests the contract creation with various metadata and salts using fuzzing.
     * @dev This fuzz test attempts to create contract instances with different metadata and salt values to ensure that each instance is created properly and the metadata URI matches the input metadata.
     * If the metadata is empty, the test returns early, assuming such input is invalid for contract creation.
     * @param _metadata Variable input metadata to test contract instance creation.
     * @param _salt Variable input salt to ensure unique contract addresses for each test case.
     */
    function testFuzzCreateInstanceWithCreate2(
        bytes calldata _metadata,
        bytes32 _salt
    ) public {
        if (_metadata.length == 0) {
            return; // Skip the test if metadata is empty, as it's considered invalid input.
        }

        uint256 contractId = marketplace.createInstanceWithCreate2(
            _metadata,
            _salt
        );
        string memory returnedURI = marketplace.tokenURI(contractId);
        assertEq(
            string(_metadata),
            returnedURI,
            "Metadata URI should match the input metadata."
        );
    }

    /**
     * @notice Fuzz test for updating the metadata URI of contract instances.
     * @dev Creates a contract instance and then attempts to update its metadata URI with various inputs to verify that updates apply correctly.
     * @param contractId The ID of the contract instance to update, generated as part of the test setup.
     * @param _newMetadataURI The new metadata URI to apply to the contract instance.
     */
    function testFuzzUpdateMetadataURI(
        uint256 contractId,
        string calldata _newMetadataURI
    ) public {
        // Set initial conditions and create a new contract instance.
        metadata = "Initial metadata";
        salt = keccak256(abi.encodePacked(block.timestamp));
        contractId = marketplace.createInstanceWithCreate2(metadata, salt);

        // Update the contract instance's metadata URI.
        marketplace.updateMetadataURI(contractId, _newMetadataURI);

        // Fetch the updated URI and assert it matches the expected new URI.
        string memory updatedURI = marketplace.tokenURI(contractId);
        assertEq(
            updatedURI,
            _newMetadataURI,
            "Metadata URI was not updated correctly."
        );
    }

    /**
     * @notice Tests the destruction of a contract instance after its metadata URI has been updated, using fuzzing.
     * @dev Creates a contract instance, updates its metadata URI, then destroys it, ensuring the contract correctly handles the destruction and subsequent actions on the destroyed instance are reverted.
     * @param _contractId A variable representing the contract instance ID, used to generate unique metadata and salt.
     * @param _newMetadataURI The new metadata URI to test the update and subsequent destruction of the contract instance.
     */
    function testFuzzDestroyContractInstanceAfterUpdate(
        uint256 _contractId,
        string calldata _newMetadataURI
    ) public {
        // Setup unique metadata and salt for contract creation.
        metadata = abi.encodePacked("Initial metadata ", _contractId);
        bytes32 uniqueSalt = keccak256(
            abi.encodePacked(_contractId, block.timestamp)
        );

        // Create a new contract instance and update its metadata URI.
        uint256 contractId = marketplace.createInstanceWithCreate2(
            metadata,
            uniqueSalt
        );
        marketplace.updateMetadataURI(contractId, _newMetadataURI);

        // Destroy the contract instance.
        marketplace.destroyContractInstance(contractId);

        // Attempt to access the destroyed contract instance should revert.
        vm.expectRevert("Contract has been destroyed.");
        marketplace.tokenURI(contractId);
    }

    /**
     * @notice Fuzz test for attempting to create a contract instance with empty metadata.
     * @dev Verifies that the contract reverts creation attempts with empty metadata, ensuring input validation.
     * @param _salt Variable input salt used to test contract creation with empty metadata.
     */
    function testFuzzCreateInstanceWithEmptyMetadata(bytes32 _salt) public {
        bytes memory emptyMetadata = "";
        vm.expectRevert(bytes("Invalid metadata"));
        marketplace.createInstanceWithCreate2(emptyMetadata, _salt);
    }

    /**
     * @notice Verifies that the contract correctly identifies the owner.
     * @dev Asserts that the owner of the marketplace contract is the same as the address deploying this test contract.
     */
    function testIsOwner() public {
        assertEq(
            marketplace.owner(),
            address(this),
            "Test contract should be the owner"
        );
    }

    /**
     * @notice Fuzz test for creating contract instances with various metadata inputs and salts.
     * @dev Attempts to create contract instances with a range of metadata inputs, expecting a revert for invalid (empty) metadata.
     * @param _metadata Variable input metadata to test different creation scenarios.
     * @param _salt Variable input salt used alongside metadata to ensure unique contract creation conditions.
     */
    function testFuzzCreateInstanceWithInvalidMetadata(
        bytes calldata _metadata,
        bytes32 _salt
    ) public {
        if (_metadata.length == 0) {
            vm.expectRevert(bytes("Invalid metadata")); // Expect a revert for empty metadata as it's considered invalid.
        }
        marketplace.createInstanceWithCreate2(_metadata, _salt);
    }
}
