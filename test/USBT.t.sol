// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {IERC165} from "../src/interfaces/IERC165.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";
import {IERC721Metadata} from "../src/interfaces/IERC721Metadata.sol";
import {USBT} from "../src/USBT.sol";
import {USBTMock} from "../src/mocks/USBTMock.sol";
import {LibString} from "solady/utils/LibString.sol";

contract USBTTest is Test {
    using LibString for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event BeforeTokenTransfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 batchSize);
    event AfterTokenTransfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 batchSize);

    string public name = "Unversal Soulbound Token";

    string public symbol = "USBT";

    string public baseURI = "baseURI/";

    uint256 public invalidTokenId = uint256(1) + type(uint160).max;

    USBTMock public usbt;

    function setUp() public {
        usbt = new USBTMock(name, symbol);
    }

    function testClaim(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        vm.expectEmit(true, true, true, true);
        emit BeforeTokenTransfer(address(0), account, tokenId, 1);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), account, tokenId);
        vm.expectEmit(true, true, true, true);
        emit AfterTokenTransfer(address(0), account, tokenId, 1);
        usbt.claim();
        assertEq(usbt.getTokenData(tokenId), 1);

        vm.expectRevert(USBT.AlreadyClaimed.selector);
        usbt.claim();

        vm.stopPrank();
    }

    function testBurn(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.burn();

        usbt.claim();

        vm.expectEmit(true, true, true, true);
        emit BeforeTokenTransfer(account, address(0), tokenId, 1);
        vm.expectEmit(true, true, true, true);
        emit Transfer(account, address(0), tokenId);
        vm.expectEmit(true, true, true, true);
        emit AfterTokenTransfer(account, address(0), tokenId, 1);
        usbt.burn();
        assertEq(usbt.getTokenData(tokenId), 3);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.burn();

        vm.stopPrank();
    }

    function testERC721Metadata(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        assertEq(usbt.name(), name);
        assertEq(usbt.symbol(), symbol);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.tokenURI(tokenId);

        usbt.claim();
        assertEq(usbt.tokenURI(tokenId), string.concat(baseURI, tokenId.toString()));

        usbt.burn();
        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.tokenURI(tokenId);

        vm.stopPrank();
    }

    function testBalanceOf(address account) public {
        vm.startPrank(account, account);
        assertEq(usbt.balanceOf(account), 0);

        usbt.claim();
        assertEq(usbt.balanceOf(account), 1);

        usbt.burn();
        assertEq(usbt.balanceOf(account), 0);

        vm.stopPrank();
    }

    function testOwnerOf(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.ownerOf(invalidTokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.ownerOf(tokenId);

        usbt.claim();
        assertEq(usbt.ownerOf(tokenId), account);

        usbt.burn();
        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.ownerOf(tokenId);

        vm.stopPrank();
    }

    function testTransfers(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.safeTransferFrom(account, address(0), invalidTokenId, "");

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.safeTransferFrom(account, address(0), invalidTokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.transferFrom(account, address(0), invalidTokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.safeTransferFrom(account, address(0), tokenId, "");

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.safeTransferFrom(account, address(0), tokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.transferFrom(account, address(0), tokenId);

        usbt.claim();
        vm.expectRevert(USBT.SoulboundToken.selector);
        usbt.safeTransferFrom(account, address(0), tokenId, "");

        vm.expectRevert(USBT.SoulboundToken.selector);
        usbt.safeTransferFrom(account, address(0), tokenId);

        vm.expectRevert(USBT.SoulboundToken.selector);
        usbt.transferFrom(account, address(0), tokenId);

        usbt.burn();
        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.safeTransferFrom(account, address(0), tokenId, "");

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.safeTransferFrom(account, address(0), tokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.transferFrom(account, address(0), tokenId);

        vm.stopPrank();
    }

    function testApprove(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.approve(address(0), invalidTokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.approve(address(0), tokenId);

        usbt.claim();

        vm.expectRevert(USBT.SoulboundToken.selector);
        usbt.approve(address(0), tokenId);

        usbt.burn();
        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.approve(address(0), tokenId);

        vm.stopPrank();
    }

    function testGetApproved(address account) public {
        vm.startPrank(account, account);
        uint256 tokenId = uint256(uint160(account));

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.getApproved(invalidTokenId);

        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.getApproved(tokenId);

        usbt.claim();
        assertEq(usbt.getApproved(tokenId), address(0));

        usbt.burn();
        vm.expectRevert(USBT.InvalidTokenId.selector);
        usbt.getApproved(tokenId);

        vm.stopPrank();
    }

    function testSetApprovalForAll(address account, address operator) public {
        vm.prank(account, account);
        vm.expectRevert(USBT.SoulboundToken.selector);
        usbt.setApprovalForAll(operator, true);
    }

    function testIsApprovedForAll(address account, address operator) public {
        assertEq(usbt.isApprovedForAll(account, operator), false);
    }

    function testERC165() public {
        assertTrue(usbt.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(usbt.supportsInterface(type(IERC721).interfaceId));
        assertTrue(usbt.supportsInterface(type(IERC165).interfaceId));
        assertFalse(usbt.supportsInterface(0xffffffff));
    }
}
