// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/ERC321Create2.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ContractMarketplaceTest is Test, Ownable {
    ContractMarketplace public marketplace;
    bytes32 public salt = keccak256("UNIQUE_SALT");
    bytes32 public salt2 = keccak256("ANOTHER_UNIQUE_SALT");
    bytes public metadata = bytes("Metadata URI");
    bytes public metadata2 = bytes("Another Metadata URI");

    constructor() Test() Ownable(msg.sender) {} // Add constructor with required arguments

    function setUp() public {
        marketplace = new ContractMarketplace();
    }

    function testCreateInstanceWithCreate2() public {}

    function testFailCreateInstanceWithSameSalt() public {
        marketplace.createInstanceWithCreate2(metadata, salt);
        marketplace.createInstanceWithCreate2(metadata2, salt);
    }

    function testCreateMultipleInstances() public {
        uint256 tokenId1 = marketplace.createInstanceWithCreate2(
            metadata,
            salt
        );
        uint256 tokenId2 = marketplace.createInstanceWithCreate2(
            metadata2,
            salt2
        );

        assertEq(tokenId1 + 1, tokenId2, "Token IDs should be sequential.");
        assertEq(
            marketplace.tokenURI(tokenId1),
            string(metadata),
            "First token URI should match."
        );
        assertEq(
            marketplace.tokenURI(tokenId2),
            string(metadata2),
            "Second token URI should match."
        );
    }

    function testTokenURIForNonexistentToken() public {
        uint256 nonExistentTokenId = 999;
        vm.expectRevert("Token does not exist.");
        marketplace.tokenURI(nonExistentTokenId);
    }

    function testCreateInstanceWithoutCreate2() public {
        uint256 tokenId = marketplace.createInstance(metadata);

        assertEq(
            tokenId,
            0,
            "Token ID should be 0 for the first contract instance created without create2."
        );
        assertEq(
            marketplace.tokenURI(tokenId),
            string(metadata),
            "Metadata URI should match for the created instance."
        );
    }

    function testInstanceAddress() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);
        address instanceAddress = marketplace.instanceAddress(tokenId);

        assertTrue(
            instanceAddress != address(0),
            "The contract instance address should not be the zero address."
        );
    }

    function testSuccessfulUpdateMetadataURI() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);

        string memory newMetadataURI = "Updated Metadata URI";
        marketplace.updateMetadataURI(tokenId, newMetadataURI);

        string memory updatedURI = marketplace.tokenURI(tokenId);
        assertEq(
            updatedURI,
            newMetadataURI,
            "The metadata URI should be successfully updated."
        );
    }

    function testUnauthorizedUpdateMetadataURI() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);
        assertEq(
            marketplace.tokenURI(tokenId),
            string(metadata),
            "Precondition: Token ID should exist."
        );

        address unauthorizedAddress = address(0xdeadbeef);
        vm.prank(unauthorizedAddress);

        (bool success, ) = address(marketplace).call(
            abi.encodeWithSelector(
                ContractMarketplace.updateMetadataURI.selector,
                tokenId,
                "Unauthorized Update Metadata URI"
            )
        );

        assertFalse(
            success,
            "Call should revert when performed by unauthorized address."
        );
    }

    function testUpdateMetadataURI() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);
        string memory newMetadataURI = "New Metadata URI";
        marketplace.updateMetadataURI(tokenId, newMetadataURI);

        assertEq(
            marketplace.tokenURI(tokenId),
            newMetadataURI,
            "The metadata URI should be updated."
        );
    }

    function testFailToUpdateMetadataURINonOwner() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);
        string memory newMetadataURI = "Unauthorized Metadata URI";
        vm.prank(address(0xdead)); // Simulate call from unauthorized address
        vm.expectRevert("Unauthorized");
        marketplace.updateMetadataURI(tokenId, newMetadataURI);
    }

    function testRevertOnCreatingInstanceWithExistingTokenID() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);
        uint256 tokenId2 = marketplace.createInstanceWithCreate2(
            metadata2,
            salt2
        );

        assertEq(
            tokenId + 1,
            tokenId2,
            "Token IDs should be sequential and unique."
        );
    }

    function testContractDestruction() public {
        uint256 tokenId = marketplace.createInstanceWithCreate2(metadata, salt);
        marketplace.destroyContractInstance(tokenId);

        vm.expectRevert("Token has been destroyed.");
        marketplace.tokenURI(tokenId);
    }

    function testNonexistentInstanceAddress() public {
        uint256 nonExistentTokenId = 999;
        vm.expectRevert("Instance does not exist.");
        marketplace.instanceAddress(nonExistentTokenId);
    }

    function testFuzzCreateInstanceWithCreate2(
        bytes calldata _metadata,
        bytes32 _salt
    ) public {
        if (_metadata.length == 0) {
            return;
        }

        uint256 tokenId = marketplace.createInstanceWithCreate2(
            _metadata,
            _salt
        );
        string memory returnedURI = marketplace.tokenURI(tokenId);
        assertEq(
            string(_metadata),
            returnedURI,
            "Metadata URI should match the input metadata."
        );
    }

    function testFuzzUpdateMetadataURI(
        uint256 tokenId,
        string calldata _newMetadataURI
    ) public {
        metadata = "Initial metadata";
        salt = keccak256(abi.encodePacked(block.timestamp));
        tokenId = marketplace.createInstanceWithCreate2(metadata, salt);

        marketplace.updateMetadataURI(tokenId, _newMetadataURI);

        string memory updatedURI = marketplace.tokenURI(tokenId);
        assertEq(
            updatedURI,
            _newMetadataURI,
            "Metadata URI was not updated correctly."
        );
    }

    function testFuzzDestroyContractInstanceAfterUpdate(
        uint256 _tokenId,
        string calldata _newMetadataURI
    ) public {
        metadata = abi.encodePacked("Initial metadata ", _tokenId);
        bytes32 uniqueSalt = keccak256(
            abi.encodePacked(_tokenId, block.timestamp)
        );

        uint256 tokenId = marketplace.createInstanceWithCreate2(
            metadata,
            uniqueSalt
        );

        marketplace.updateMetadataURI(tokenId, _newMetadataURI);

        marketplace.destroyContractInstance(tokenId);

        vm.expectRevert("Token has been destroyed.");
        marketplace.tokenURI(tokenId);
    }


    function testFuzzCreateInstanceWithEmptyMetadata(bytes32 _salt) public {
        bytes memory emptyMetadata = "";
        vm.expectRevert(bytes("Invalid metadata"));
        marketplace.createInstanceWithCreate2(emptyMetadata, _salt);
    }

    function testIsOwner() public {
        assertEq(
            marketplace.owner(),
            address(this),
            "Test contract should be the owner"
        );
    }

    function testFuzzCreateInstanceWithInvalidMetadata(
        bytes calldata _metadata,
        bytes32 _salt
    ) public {
        if (_metadata.length == 0) {
            vm.expectRevert(bytes("Invalid metadata"));
        }
        marketplace.createInstanceWithCreate2(_metadata, _salt);
    }


}
