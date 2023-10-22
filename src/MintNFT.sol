// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * - totalSupply: 500
 * - mint(): 基本正常 mint，不要達到上限 500 即可
 * - randomMint() 加分項目，隨機 mint tokenId (不重複)
 *   - 隨機的方式有以下選擇方式
 *     - 自己製作隨機 random，不限任何方法
 *     - Chainlink VRF
 *     - RANDAO
 * - Implement 盲盒機制
 * - 請寫測試確認解盲前的 tokenURI 及解盲後的 tokenURI
 */

error MaximumSupplyReached();

contract MintNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 public totalSupply;
    uint256 public maxSupply = 500;
    string private _baseuri;
    mapping(uint256 => bool) private _tokenExists;

    constructor(address createor) ERC721("MintNFT", "MIN") Ownable(createor) {
      _baseuri = "https://ipfs.io/ipfs/DIRECT_TO_BEFORE_UNBLIND_LINK/";
    }

    function mint(address to) public returns(uint256) {
      if (totalSupply >= maxSupply) {
        revert MaximumSupplyReached();
      }

      uint256 tokenId = totalSupply + 1;
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, Strings.toString(tokenId));
      totalSupply++;

      return tokenId;
    }

    function randomMint(address to) public returns(uint256) {
      if (totalSupply >= maxSupply) {
        revert MaximumSupplyReached();
      }

      uint256 tokenId = _generateRandomTokenId();
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, Strings.toString(tokenId));
      totalSupply++;
      _tokenExists[tokenId] = true;
      
      return tokenId;
    }

    function _generateRandomTokenId() private view returns (uint256) {
      uint256 tokenId;
      do {
          tokenId = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, totalSupply)));
          tokenId = tokenId % maxSupply;
          tokenId++;
      } while (_tokenExists[tokenId]);

      return tokenId;
    }


    function unblinding(string calldata newBaseURI) external onlyOwner {
      _setBaseURI(newBaseURI);
    }

    function _setBaseURI(string calldata baseURI) internal onlyOwner {
      _baseuri = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
      return _baseuri;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
