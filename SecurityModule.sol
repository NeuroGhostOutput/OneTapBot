// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SecurityModule is Ownable {
    mapping(address => bool) private blacklist;
    mapping(address => bool) private whitelistedTokens;  // Only allow trusted tokens

    function addToBlacklist(address _address) external onlyOwner {
        blacklist[_address] = true;
    }

    function removeFromBlacklist(address _address) external onlyOwner {
        blacklist[_address] = false;
    }

    function isBlacklisted(address _address) external view returns (bool) {
        return blacklist[_address];
    }

    function addToWhitelist(address _token) external onlyOwner {
        whitelistedTokens[_token] = true;
    }

    function removeFromWhitelist(address _token) external onlyOwner {
        whitelistedTokens[_token] = false;
    }

    function isTokenWhitelisted(address _token) external view returns (bool) {
        return whitelistedTokens[_token];
    }
}
