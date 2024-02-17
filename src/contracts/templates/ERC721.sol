// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ERC721Example is ERC721, ERC721URIStorage, Ownable {
    constructor() ERC721("MyERC721Token", "M721") Ownable(msg.sender) {}

    function safeMint(address to, uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage)  returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}