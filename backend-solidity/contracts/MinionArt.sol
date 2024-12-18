// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the necessary contracts for minion art functionality
import { ERC721, ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { IMinionErrors } from "./MinionErrors.sol";

/**
 * @title MinionArt
 * @dev This contract implements the ERC721URIStorage and allows for the creation and management of MinionArt tokens.
 */
contract MinionArt is ERC721URIStorage, IMinionErrors {
	// Variable to keep track of the next available token ID
	uint256 public nextTokenId;

	// Event to be emitted when a new token is minted
	event MintMinted(uint256 indexed tokenId, address owner, string tokenURI);

	/**
	 * @dev Initializes the contract with the specified market address.
	 * @param _marketAddress The address of the market contract.
	 */
	constructor(address _marketAddress) ERC721("MinionArt", "MNA") {}

	/**
	 * @dev Mints a new token with the provided owner and token URI.
	 * @param _owner The address of the new token owner.
	 * @param _tokenURI The URI of the token's metadata.
	 */
	function mint(address _owner, string memory _tokenURI) external {
		_safeMint(_owner, nextTokenId);
		_setTokenURI(nextTokenId, _tokenURI);

		emit MintMinted(nextTokenId, _owner, _tokenURI);

		++nextTokenId;
	}

	/**
	 * @dev Returns an array of all token IDs owned by the caller.
	 * @return An array of token IDs owned by the caller.
	 */
	function getOwnedArtionByAddress() external view returns (uint256[] memory) {
		uint256 ownedCount = balanceOf(msg.sender);
		uint256[] memory ownedTokenIds = new uint256[](ownedCount);
		uint256 currentIndex = 0;

		for (uint256 i = 0; i < nextTokenId; ++i) {
			if (getArtionOwner(i) == msg.sender) {
				ownedTokenIds[currentIndex++] = i;
			}
		}

		return ownedTokenIds;
	}

	/**
	 * @dev Returns the owner of the specified token ID.
	 * @param _tokenId The ID of the token to query.
	 * @return The address of the token owner.
	 */
	function getArtionOwner(uint256 _tokenId) public view returns (address) {
		address owner = ownerOf(_tokenId);

		if (owner == address(0)) {
			revert MNTNotexist(_tokenId);
		}

		return owner;
	}
}
