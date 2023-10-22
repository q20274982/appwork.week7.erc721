// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {HW_Token, NoUseFul, NFT_Receiver, UAreNotRightContract} from "../src/NoNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NoNFTTest is Test {
  HW_Token public hwTokenErc721;
  NoUseFul public noUseFulErc721;
  NFT_Receiver public nftReceiver;

  address public user1;
  
  function setUp() public {
    hwTokenErc721 = new HW_Token();
    noUseFulErc721 = new NoUseFul();
    nftReceiver = new NFT_Receiver(address(hwTokenErc721));

    user1 = makeAddr("user1");
  }

  function test_HW_TOKEN_name() public {
    assertEq(hwTokenErc721.name(), "Don't send NFT to me");
  }

  function test_HW_TOKEN_symbol() public {
    assertEq(hwTokenErc721.symbol(), "NONFT");
  }

  // 當 user1 mint NUF contract 應該要收到 NUF NFT 
  function test_when_user1_mint_NUF_should_receive_NUF_NFT() public {
    uint256 tokenId = 20;
    noUseFulErc721.safeMint(user1, tokenId);

    assertEq(
      IERC721(noUseFulErc721).ownerOf(tokenId),
      address(user1)
    );
  }

  // 當 user1 調用 NUF 的 safeTransferFrom 到 NFT_Reciever 時, 要收到 NUF & HW_Token
  function test_when_call_NUF_safeTransferFrom_to_NFT_Receiver_should_received_NUF_and_HW_Token() public {
    // 1. user1 mint NUF: 20
    uint256 tokenId = 20;
    address to = makeAddr("to");
    noUseFulErc721.safeMint(user1, tokenId);
    assertEq(
      noUseFulErc721.ownerOf(tokenId),
      address(user1)
    );
    
    uint256 user1Hwbalance = hwTokenErc721.balanceOf(user1);
    
    // 2. user1 call NUF.safeTransferFrom transfer NUF: 20 to NFT_Receiver
    vm.prank(user1);
    noUseFulErc721.approve(to, tokenId);
    vm.prank(to);
    noUseFulErc721.safeTransferFrom(user1, address(nftReceiver), tokenId);
    
    // 3. user1 sould received NUF: 20 and new HW_Token
    assertEq(
      noUseFulErc721.ownerOf(tokenId),
      address(user1)
    );
    assertEq(
      hwTokenErc721.balanceOf(user1),
      user1Hwbalance + 1
    );
  }

  // 當 user1 調用 HW_Token 的 safeTransferFrom 到 NFT_Reciever 時, NFT_Receiver 會收到 NFT
  function test_when_call_HW_Token_safeTransferFrom_to_NFT_Receiver_should_received_HW_Token() public {
    // 1. user1 mint HW_Token: 20
    uint256 tokenId = 20;
    address to = makeAddr("to");
    hwTokenErc721.safeMint(user1, tokenId);
    assertEq(
      hwTokenErc721.ownerOf(tokenId),
      address(user1)
    );
    
    // 2. user1 call HW_Token.safeTransferFrom transfer HW_Token: 20 to NFT_Receiver
    vm.prank(user1);
    hwTokenErc721.approve(to, tokenId);
    vm.prank(to);
    hwTokenErc721.safeTransferFrom(user1, address(nftReceiver), tokenId);
    
    // 3. NFT_Receiver sould received HW_Token: 20
    assertEq(
      hwTokenErc721.ownerOf(tokenId),
      address(nftReceiver)
    );
  }
}
