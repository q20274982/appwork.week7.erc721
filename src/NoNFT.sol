// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * - name(): Don’t send NFT to me。
 * - symbol(): “NONFT”
 * - metadata image:  “https://imgur.com/IBDi02f”
 * - 功能：
 *   1. Receiver 收到一個的其他 ERC721 token (此 Token 隨意設計就行)，
 *      若此 Token 非我們上述的 NONFT Token，就將其傳回去給原始 Token owner，同時 mint 一個這個 NONFT token 給 owner。
 *   2. ERC721 請與 Receiver 分成兩個不同的合約。
 *   3. 需測試執行完畢原始的 sender 可以收到原本的 token + NONFT token
 */

abstract contract SoSafe is ERC721 {
  function safeMint(address to, uint256 tokenId) public {
    _safeMint(to, tokenId);
  }
}

contract NoUseFul is ERC721, SoSafe {
  // EOA should mint token and call safeTransferFrom in this ERC721 contract first.
  constructor() ERC721("No Useful", "NUF") {}
}

contract HW_Token is ERC721, SoSafe {
// 1. Create ERC721 token with name and symbol
// 2. Write a mint function to mint the static ERC721 token
// 3. The NFT is always return the same metadata
  constructor() ERC721("Don't send NFT to me", "NONFT") {}
}

error UAreNotRightContract();

contract NFT_Receiver is IERC721Receiver {
  // 1. Check the msg.sender(NoUseFul contract) is same as your HW_Token contract
  // 2. If not, please transfer the NoUseful token back to the original owner
  // 3. and also mint the HW_Token to the original owner
  address private _hw_token;

  constructor(address addr) {
    _hw_token = addr;
  }
  
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) public virtual override returns (bytes4) {
    if (msg.sender != _hw_token) {
      ERC721(msg.sender).safeTransferFrom(address(this), from, tokenId);
      HW_Token(_hw_token).safeMint(address(this), tokenId);
      HW_Token(_hw_token).safeTransferFrom(address(this), from, tokenId);
    }

    return IERC721Receiver.onERC721Received.selector;
  }
}