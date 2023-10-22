// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {MintNFT, MaximumSupplyReached} from "../src/MintNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MintNFTTest is Test {
  MintNFT public mintNft;
  address public owner;
  address public user1;
  
  function setUp() public {
    owner = makeAddr("owner");
    mintNft = new MintNFT(owner);
    user1 = makeAddr("user1");
  }

  // mint 可以正常 mint
  function test_when_call_mint_should_return_minted_tokenId() public {
    (bool isSuccess, bytes memory data) = address(mintNft).call(
      abi.encodeWithSignature(
      "mint(address)",
      user1
    ));
    (uint256 tokenId) = abi.decode(data, (uint256));

    assertTrue(isSuccess);
    assertGt(tokenId,0);
  }

  // randomMint 可以正常 mint
  function test_when_call_randomMint_should_return_minted_tokenId() public {
    (bool isSuccess, bytes memory data) = address(mintNft).call(
      abi.encodeWithSignature(
      "randomMint(address)",
      user1
    ));
    (uint256 tokenId) = abi.decode(data, (uint256));

    assertTrue(isSuccess);
    assertGt(tokenId,0);
  }

  // mint 超過 500 個, 要收到 error
  function test_when_call_mint_over_500_times_should_get_error() public {
    address jiucai = makeAddr("jiucai");
    for(uint i = 0; i < 500; i++){
      mintNft.mint(jiucai);
    }

    vm.expectRevert(MaximumSupplyReached.selector);
    mintNft.mint(jiucai);
  }

  // randomMint 超過 500 個, 要收到 error
  function test_when_call_randomMint_over_500_times_should_get_error() public {
    address jiucai = makeAddr("jiucai");
    for(uint i = 0; i < 500; i++){
      mintNft.mint(jiucai);
    }

    vm.expectRevert(MaximumSupplyReached.selector);
    mintNft.randomMint(jiucai);
  }

  // owner call unblinding 應該成功
  function test_when_owner_call_unblinding_should_pass() public {
    vm.startPrank(owner);
    (bool isSuccess,) = address(mintNft).call(
      abi.encodeWithSignature(
      "unblinding(string)",
      "foo"
    ));
    vm.stopPrank();

    assertTrue(isSuccess);
  }

  // 非 owner call unblinding 應該被 revert
  function test_when_luren_call_unblinding_should_kickout() public {
    vm.startPrank(user1);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
    mintNft.unblinding("foo");
    vm.stopPrank();
  }

  // unblinding 後, tokenURI 要符合預期
  function test_when_call_unblinding_should_replace_ever_token_tokenURI() public {
    uint256 tokenId = mintNft.mint(user1);
    string memory beforeTokenURI = mintNft.tokenURI(tokenId);

    assertEq(
      beforeTokenURI,
      string.concat("https://ipfs.io/ipfs/DIRECT_TO_BEFORE_UNBLIND_LINK/", Strings.toString(tokenId))
    );
    
    string memory unblindURI = "https://ipfs.io/ipfs/DIRECT_TO_AFTER_UNBLIND_LINK/";
    vm.startPrank(owner);
    mintNft.unblinding(unblindURI);
    string memory afterTokenURI = mintNft.tokenURI(tokenId);

    assertEq(
      afterTokenURI,
      string.concat("https://ipfs.io/ipfs/DIRECT_TO_AFTER_UNBLIND_LINK/", Strings.toString(tokenId))
    );

    assertEq(
      keccak256(abi.encodePacked(afterTokenURI)) != keccak256(abi.encodePacked(beforeTokenURI)),
      true
    );
  }
}