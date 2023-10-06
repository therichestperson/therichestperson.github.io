// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TheRichestPerson is ERC721 {

    struct Bidder {
        address bidderAddress;
        string username;
        uint256 bidAmount;
        uint256 tokenId;
    }

    Bidder public topBidder;
    uint256 public highestBid;

    Bidder[] public biddersArray; // Array to store all bidders

    address payable public owner; // This will store your address

    uint256 public nextNFTId = 10000; // Start NFT IDs from 10,000

    event TransferFailed(address recipient, uint256 tokenId); // Event to log if NFT transfer fails

    constructor() ERC721("The Richest Person", "TRP") {
        owner = payable(msg.sender); // Set the contract deployer as the owner
    }

    function bid(string memory _username) external payable {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(msg.value > highestBid, "Bid must exceed the current highest bid");
        require(nextNFTId >= 1, "Maximum number of bidders reached");

        highestBid = msg.value;

        Bidder memory newBidder = Bidder({
            bidderAddress: msg.sender,
            username: _username,
            bidAmount: msg.value,
            tokenId: nextNFTId
        });

        biddersArray.push(newBidder);
        topBidder = newBidder; // Update the topBidder immediately

        // Transfer the funds to the owner
        owner.transfer(msg.value);

        // Attempt to transfer the minted token to the bidder
        _trySafeTransfer(owner, msg.sender, nextNFTId);

        nextNFTId--; // Decrease the nextNFTId for the next bidder
    }

    function _trySafeTransfer(address from, address to, uint256 tokenId) internal {
        try this.safeTransferFrom(from, to, tokenId) {
            // Successfully transferred the token
        } catch {
            emit TransferFailed(to, tokenId); // Log the failure
        }
    }

    function getTopBidder() external view returns (Bidder memory) {
        return topBidder;
    }

    function getAllBidders() external view returns (Bidder[] memory) {
        return biddersArray;
    }
}
