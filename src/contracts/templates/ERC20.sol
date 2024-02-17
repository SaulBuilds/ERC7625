// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ERC20Example is ERC20Burnable, Ownable(msg.sender) {
constructor() ERC20("ERC20Example", "EXAMPLE") {
    _mint(msg.sender, 1000 * (10 ** uint256(decimals())));
}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}