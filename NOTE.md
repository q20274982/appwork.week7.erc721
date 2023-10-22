1. create user1 with `makeAddr` pretend as EOA
2. user1 mint NUF at first
3. user1 transfer NUF to `NFT_Receiver` by called `safeTransferFrom`.
4. NFT_Receiver's `onERC721Received` inner process
   1. check is the sender equal to `NONFT`
   2. if Not, return the NUF to owner, also mint the new `HW_Token` to owner.
5. need to test is the user1 receive the NUF & NONFT token.