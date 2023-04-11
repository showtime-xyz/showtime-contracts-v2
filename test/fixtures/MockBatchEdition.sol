// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IBatchEdition} from "nft-editions/interfaces/IBatchEdition.sol";

contract MockBatchEdition is IBatchEdition {
    mapping(address => bool) public approvedMinter;

    function contractURI() external pure returns (string memory) {
        return "mock";
    }

    function getPrimaryOwnersPointer() external pure returns (address) {
        return address(0);
    }

    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _animationUrl,
        string memory _imageUrl,
        uint256 _editionSize,
        uint256 _royaltyBPS,
        uint256 _mintPeriodSeconds
    ) external override {
        approvedMinter[_owner] = true;
    }


    function isPrimaryOwner(
        address /* tokenOwner */
    ) external pure returns (bool) {
        // mock mock mock
        return false;
    }

    function mintBatch(
        bytes calldata addresses
    ) external view override returns (uint256) {
        require(approvedMinter[msg.sender], "UNAUTHORIZED_MINTER");
        return addresses.length / 20;
    }

    function mintBatch(address pointer) external override returns (uint256) {
        // mockedy mock mock
    }

    function setExternalUrl(string calldata _externalUrl) external {
        // mockedy mock mock
    }

    function setStringProperties(
        string[] calldata names,
        string[] calldata values
    ) external {
        // mockedy mock mock
    }

    function totalSupply() external pure returns (uint256) {
        return 0;
    }

    function withdraw() external {
        // mockedy mock mock
    }

    function transferOwnership(address newOwner) external {
        // mockedy mock mock
    }

    function editionSize() external view override returns (uint256) {}

    function enableDefaultOperatorFilter() external override {}

    function endOfMintPeriod() public view override returns (uint256) {}

    function isApprovedMinter(
        address minter
    ) external view override returns (bool) {
        return approvedMinter[minter];
    }

    function isMintingEnded() external view override returns (bool) {
        return block.timestamp > endOfMintPeriod();
    }

    function setApprovedMinter(
        address minter,
        bool allowed
    ) external override {
        approvedMinter[minter] = allowed;
    }

    function setOperatorFilter(address operatorFilter) external override {}

    function getPrimaryOwnersPointer(
        uint256 index
    ) external view override returns (address) {}
}
