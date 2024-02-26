// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MarkNFTMarketplace is ERC721, Ownable {
    using Math for uint256;

    uint256 public tokenIdCounter;
    mapping(uint256 => uint256) public tokenIdToPrice;
    mapping(uint256 => address) public tokenIdToSeller;

    event NFTMinted(uint256 indexed tokenId, address indexed owner, uint256 price);
    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
        _;
    }

    modifier notTokenOwner(uint256 _tokenId) {
        require(ownerOf(_tokenId) != msg.sender, "You cannot buy your own token");
        _;
    }

    constructor() ERC721("MarkNFT", "MNFT") Ownable(msg.sender){}

    function mintNFT(uint256 _price) external returns (uint256) {
        tokenIdCounter++;
        uint256 tokenId = tokenIdCounter;
        _safeMint(msg.sender, tokenId);
        tokenIdToPrice[tokenId] = _price;
        tokenIdToSeller[tokenId] = msg.sender;
        emit NFTMinted(tokenId, msg.sender, _price);
        return tokenId;
    }

    function listNFTForSale(uint256 _tokenId, uint256 _price) external onlyTokenOwner(_tokenId) {
        tokenIdToPrice[_tokenId] = _price;
        tokenIdToSeller[_tokenId] = msg.sender;
        emit NFTListed(_tokenId, _price);
    }

    function buyNFT(uint256 _tokenId) external payable notTokenOwner(_tokenId) {
        address seller = tokenIdToSeller[_tokenId];
        uint256 price = tokenIdToPrice[_tokenId];
        require(msg.value >= price, "Insufficient payment");

        // Set price to 0 to mark it as sold
        tokenIdToPrice[_tokenId] = 0;

        // Clear seller address
        tokenIdToSeller[_tokenId] = address(0);

        // Transfer ownership
        _safeTransfer(seller, msg.sender, _tokenId);

        // Send payment to seller
        payable(seller).transfer(price);

        emit NFTSold(_tokenId, msg.sender, seller, price);
    }

    function getNFTPrice(uint256 _tokenId) external view returns (uint256) {
        return tokenIdToPrice[_tokenId];
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
