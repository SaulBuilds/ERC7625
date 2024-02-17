// SPDX-License-Identifier: MIT
/**
 * @title ERC321
 * @author Larry Klosowski @ QuFoamLabs 
 * @notice This contract is a simple implementation of 
 * deployment of an ERC321 contract that implements 
 * the 'new' function to create a contract.
 */
pragma solidity ^0.8.23;

import "../interfaces/IERC321Metadata.sol";
import "./templates/ERC20.sol";

contract SmartContractMarketplace is IERC321Metadata, Ownable(msg.sender) {
    ERC20Example private newContract;
    uint256 private _nextTokenId;
    mapping(uint256 => address) private _contractInstances;
    mapping(uint256 => string) private _metadataURIs;

    function createSmartContract(
        bytes calldata _metadata
    ) external  returns (uint256 tokenId) {
        tokenId = _nextTokenId++;
        // Example contract creation. Replace `ExampleContract` with actual contract class
        newContract = new ERC20Example();
        _contractInstances[tokenId] = address(newContract);
        _metadataURIs[tokenId] = string(_metadata);
        emit ContractInstanceCreated(address(newContract), tokenId);
    }

    function tokenURI(
        uint256 _tokenId
    ) external view override returns (string memory) {
        return _metadataURIs[_tokenId];
    }

    function instanceAddress(uint256 _tokenId) public view returns (address) {
        require(_tokenId < _nextTokenId, "Instance does not exist.");
        return _contractInstances[_tokenId];
    }   

      function createInstance(bytes calldata _metadata) external override returns (uint256 tokenId) {
        tokenId = _nextTokenId++;
        // Assuming a default contract to deploy for this example. Adjust as needed.
        newContract = new ERC20Example();
        _contractInstances[tokenId] = address(newContract);
        _metadataURIs[tokenId] = string(_metadata);
        emit ContractInstanceCreated(address(newContract), tokenId);
    }
}