// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the necessary OpenZeppelin contracts for ERC20 token functionality
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MinionCoin
 * @dev This contract implements the ERC20 standard and allows for the creation and management of MinionCoin tokens.
 */
contract MinionCoin is ERC20 {
	/**
	 * @dev Initializes the MinionCoin contract with the specified initial supply.
	 * @param _initialSupply The initial supply of MinionCoin tokens.
	 */
	constructor(uint256 _initialSupply) ERC20("MinionCoin", "MNC") {
		// Set the initial supply of MinionCoin tokens
		_mint(msg.sender, _initialSupply);
	}
}
