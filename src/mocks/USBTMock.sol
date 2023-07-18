// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {USBT} from "../USBT.sol";

contract USBTMock is USBT {
    event BeforeTokenTransfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 batchSize);
    event AfterTokenTransfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 batchSize);

    constructor(string memory name_, string memory symbol_) USBT(name_, symbol_) {}

    function claim() external {
        _claim();
    }

    function burn() external {
        _burn();
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override
    {
        emit BeforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override {
        emit AfterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "baseURI/";
    }

    function getTokenData(uint256 tokenId) external view returns (uint256) {
        return _tokenData[tokenId];
    }
}
