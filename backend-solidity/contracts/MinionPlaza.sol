// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MinionArt } from "./MinionArt.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract MinionPlaza is Ownable {
	using ECDSA for bytes32;
	using SafeERC20 for IERC20;

	// Define the domain separator
	bytes32 public constant DOMAIN_TYPEHASH =
		keccak256(
			"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
		);
	bytes32 public constant ORDER_TYPEHASH =
		keccak256(
			"Order(address seller,address nftContract,uint256 tokenId,uint256 price,address paymentToken,uint256 expirationTime)"
		);

	string public constant NAME = "MinionPlaza";
	string public constant VERSION = "1.0";

	// Domain separator
	bytes32 public DOMAIN_SEPARATOR;

	// Struct to represent the order
	struct Order {
		address seller;
		address nftContract;
		uint256 tokenId;
		uint256 price;
		address paymentToken;
		uint256 expirationTime;
	}

	// Mapping to store executed orders (to prevent replay attacks)
	mapping(bytes32 => bool) public executedOrders;

	// Event emitted on successful purchase
	event OrderFulfilled(
		address indexed buyer,
		address indexed seller,
		address indexed nftContract,
		uint256 tokenId,
		uint256 price,
		address paymentToken
	);

	constructor(address _initialOwner) Ownable(_initialOwner) {
		DOMAIN_SEPARATOR = keccak256(
			abi.encode(
				DOMAIN_TYPEHASH,
				keccak256(bytes(NAME)),
				keccak256(bytes(VERSION)),
				block.chainid,
				address(this)
			)
		);
	}

	/**
	 * @dev Fulfill an order to purchase an NFT using ERC-20 tokens
	 * @param seller The address of the seller
	 * @param nftContract The NFT contract address
	 * @param tokenId The token ID of the NFT
	 * @param price The price in ERC-20 tokens
	 * @param paymentToken The ERC-20 token used for payment
	 * @param expirationTime The expiration timestamp for the order
	 * @param signature The seller's signature
	 */
	function fulfillOrder(
		address seller,
		address nftContract,
		uint256 tokenId,
		uint256 price,
		address paymentToken,
		uint256 expirationTime,
		bytes calldata signature
	) external {
		// Ensure the order has not expired
		require(block.timestamp <= expirationTime, "Order expired");

		// Construct the order hash
		bytes32 orderHash = keccak256(
			abi.encodePacked(
				ORDER_TYPEHASH,
				seller,
				nftContract,
				tokenId,
				price,
				paymentToken,
				expirationTime,
				address(this)
			)
		);

		// Ensure the order has not already been executed
		require(!executedOrders[orderHash], "Order already executed");

		// Create the message hash for EIP-712
		bytes32 messageHash = keccak256(
			abi.encodePacked("\x19MINION_PLAZA_SIGN:\n32", DOMAIN_SEPARATOR, orderHash)
		);

		// Recover the signer address from the signature
		(uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
		address signer = ecrecover(messageHash, v, r, s);

		// Ensure the recovered signer is the seller
		require(signer == seller, "Invalid signature");

		// Mark the order as executed
		executedOrders[orderHash] = true;

		// Transfer MinionCoin from buyer to the seller
		IERC20(paymentToken).safeTransferFrom(msg.sender, seller, price);

		// Transfer the NFT from the seller to the buyer
		MinionArt(nftContract).safeTransferFrom(seller, msg.sender, tokenId);

		// Emit an event for the fulfilled order
		emit OrderFulfilled(
			msg.sender,
			seller,
			nftContract,
			tokenId,
			price,
			paymentToken
		);
	}

	// Helper function to split the signature into v, r, s
	function splitSignature(
		bytes memory sig
	) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
		require(sig.length == 65, "Invalid signature length");

		assembly {
			r := mload(add(sig, 32))
			s := mload(add(sig, 64))
			v := byte(0, mload(add(sig, 96)))
		}

		// Adjust v if necessary
		if (v < 27) {
			v += 27;
		}
	}
}
