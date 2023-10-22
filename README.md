
# Appworks week7 assignment

## Test Result
[![test](https://github.com/q20274982/appwork.week7.erc721/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/q20274982/appwork.week7.erc721/actions/workflows/test.yml)

## 作業1 - 請實作一個 ERC721 token 和 Receiver Contract
```
- name(): Don’t send NFT to me。
- symbol(): “NONFT”
- metadata image:  “https://imgur.com/IBDi02f”
- 功能：
  1. Receiver 收到一個的其他 ERC721 token (此 Token 隨意設計就行)，若此 Token 非我們上述的 NONFT Token，就將其傳回去給原始 Token owner，同時 mint 一個這個 NONFT token 給 owner。
  2. ERC721 請與 Receiver 分成兩個不同的合約。
  3. 需測試執行完畢原始的 sender 可以收到原本的 token + NONFT token
```

## 作業2 - 做一個隨機自由 mint token 的 ERC721
```
- totalSupply: 500
- mint(): 基本正常 mint，不要達到上限 500 即可
- randomMint() 加分項目，隨機 mint tokenId (不重複)
  - 隨機的方式有以下選擇方式
    - 自己製作隨機 random，不限任何方法
    - Chainlink VRF
    - RANDAO
- Implement 盲盒機制
- 請寫測試確認解盲前的 tokenURI 及解盲後的 tokenURI
```
