// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "../interfaces/IERC321Metadata.sol";
import "./templates/ERC721.sol"; // Assuming this is an ERC721 contract

contract ContractMarketplace is IERC321Metadata, Ownable {
    uint256 private _nextTokenId;
    mapping(uint256 => address) private _contractInstances;
    mapping(uint256 => string) private _metadataURIs;




    constructor() Ownable(msg.sender) {
 
        _nextTokenId = 0; 
    }

    function createInstanceWithCreate2(
        bytes calldata _metadata, bytes32 _salt) 
        external returns (
            uint256 tokenId) {
        require(_metadata.length > 0, "Invalid metadata"); // Ensure metadata is not empty

        bytes memory bytecode = abi.encodePacked(
            type(ERC721Example).creationCode
        );
        address instance = Create2.deploy(0, _salt, bytecode);
        require(instance != address(0), "Failed to deploy contract");

        tokenId = _nextTokenId++;
        _contractInstances[tokenId] = instance;
        _metadataURIs[tokenId] = string(_metadata);

        emit ContractInstanceCreated(instance, tokenId);
    }

    function tokenURI(uint256 _tokenId) external view override returns (string memory) {
        require(_tokenId < _nextTokenId, "Token does not exist.");
        require(_contractInstances[_tokenId] != address(0), "Token has been destroyed.");
        return _metadataURIs[_tokenId];
    }

    function instanceAddress(uint256 tokenId) public view returns (address) {
        require(tokenId < _nextTokenId, "Instance does not exist.");
        return _contractInstances[tokenId];
    }

    function updateMetadataURI(
        uint256 _tokenId,
        string calldata _newMetadataURI
    ) external onlyOwner {
        require(_tokenId < _nextTokenId, "Token does not exist.");
        _metadataURIs[_tokenId] = _newMetadataURI;
    }

    function destroyContractInstance(uint256 _tokenId) external onlyOwner {
        require(_tokenId < _nextTokenId, "Instance does not exist.");
        delete _contractInstances[_tokenId];
        delete _metadataURIs[_tokenId];
    }

    function createInstance(bytes calldata _metadata) external returns (uint256 tokenId) {
        ERC721Example newContract = new ERC721Example(); // Assuming ERC721Example's constructor does not require parameters
        address newContractAddress = address(newContract);

        tokenId = _nextTokenId++;
        _contractInstances[tokenId] = newContractAddress;
        _metadataURIs[tokenId] = string(_metadata);

        emit ContractInstanceCreated(newContractAddress, tokenId);
    }
}