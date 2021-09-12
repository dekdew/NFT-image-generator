// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.3.1/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.3.1/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.3.1/access/Ownable.sol";

contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 public mintPrice = 0.001 ether;
    uint256 public maxItems = 100;
    uint256 public totalSupply = 0;
    uint256 public maxItemsPerTx = 5;
    string public _baseTokenURI;

    event Mint(address indexed owner, uint256 indexed tokenId);

    constructor() ERC721("MyNFT", "MNFT") {}

    receive() external payable {}

    function publicMint() external payable {
        uint256 remainder = msg.value % mintPrice;
        uint256 amount = msg.value / mintPrice;
        require(remainder == 0, "publicMint: Send a divisible amount of eth");
        require(amount <= maxItemsPerTx, "publicMint: Surpasses maxItemsPerTx");

        _mintWithoutValidation(msg.sender, amount);
    }

    function _mintWithoutValidation(address to, uint256 amount) internal {
        require(
            totalSupply + amount <= maxItems,
            "mintWithoutValidation: Sold out"
        );
        for (uint256 i = 0; i < amount; i++) {
            _mint(to, totalSupply);
            emit Mint(to, totalSupply);
            totalSupply += 1;
        }
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setMaxItemsPerTx(uint256 _maxItemsPerTx) external onlyOwner {
        maxItemsPerTx = _maxItemsPerTx;
    }

    function setBaseTokenURI(string memory __baseTokenURI) external onlyOwner {
        _baseTokenURI = __baseTokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return
            string(abi.encodePacked(_baseTokenURI, Strings.toString(_tokenId)));
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /**
     * @dev Withdraw the contract balance to the dev address or splitter address
     */
    function withdraw() external onlyOwner {
        sendEth(owner(), address(this).balance);
    }

    function sendEth(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Failed to send ether");
    }
}
