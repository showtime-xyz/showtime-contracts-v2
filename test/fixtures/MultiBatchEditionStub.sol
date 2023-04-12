// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SSTORE2} from "solmate/utils/SSTORE2.sol";

import {IBatchEdition} from "nft-editions/interfaces/IBatchEdition.sol";

contract MultiBatchEditionStub is IBatchEdition {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    mapping(address => bool) public approvedMinter;
    address[] public primaryOwnerPointers;

    // TODO: pack state variables
    uint256 public totalSupply;
    uint256 public maxSupply;

    function contractURI() external pure returns (string memory) {
        return "simple";
    }

    function getPrimaryOwnersPointer() external pure returns (address) {
        return address(0);
    }

    function initialize(
        address, // _owner
        string calldata, // _name,
        string calldata, // _symbol,
        string calldata, // _description,
        string calldata, // _animationUrl,
        string calldata, // _imageUrl,
        uint256, // _royaltyBPS,
        address _minter
    ) external {
        approvedMinter[_minter] = true;
    }

    // TODO: should be part of initializer
    function setMaxSupply(uint256 _maxSupply) external {
        maxSupply = _maxSupply;
    }

    function isPrimaryOwner(address tokenOwner) external view returns (bool) {
        // TODO: we do a grossly inefficient linear search across all primary owners
        // ideally, we would do a binary search across pointers
        uint256 n = primaryOwnerPointers.length;
        for (uint256 i = 0; i < n; i++) {
            if (contains(primaryOwnerPointers[i], tokenOwner) == 1) {
                return true;
            }
        }

        return false;
    }

    function mintBatch(bytes calldata addresses) external override returns (uint256) {
        require(approvedMinter[msg.sender], "UNAUTHORIZED_MINTER");
        require(addresses.length % 20 == 0, "INVALID_ADDRESSES");

        // TODO: use efficient technique to iterate over calldata
        address pointer = SSTORE2.write(addresses);
        return mintBatch(pointer);
    }

    function mintBatch(address pointer) public override returns (uint256) {
        require(approvedMinter[msg.sender], "UNAUTHORIZED_MINTER");

        uint256 n = length(pointer);
        require(n > 0, "INVALID_ADDRESSES");

        // TODO: fix grossly inefficient loop
        for (uint256 i = 1; i <= n; i++) {
            // TODO: validate that addresses are sorted
            // TODO: fetch once, iterate in memory
            address owner = fetch(pointer, i);
            emit Transfer(address(0), owner, totalSupply + i);
        }

        // TODO: rewrite so that it works with single SLOAD and a single SSTORE
        totalSupply += n;
        require(totalSupply <= maxSupply, "MAX_SUPPLY_EXCEEDED");

        primaryOwnerPointers.push(pointer);

        return n;
    }

    function setExternalUrl(string calldata _externalUrl) external {
        // mockedy mock mock
    }

    function setStringProperties(string[] calldata names, string[] calldata values) external {
        // mockedy mock mock
    }

    function transferOwnership(address newOwner) external {
        // mockedy mock mock
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function contains(address pointer, address owner) internal view returns (uint256) {
        uint256 low = 1;
        uint256 high = length(pointer);
        uint256 mid = (low + high) / 2;

        while (low <= high) {
            address midOwner = fetch(pointer, mid);
            if (midOwner == owner) {
                return 1;
            } else if (midOwner < owner) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
            mid = (low + high) / 2;
        }

        return 0;
    }

    /// @dev returns the length in number of addresses (not bytes)
    function length(address pointer) internal view returns (uint256) {
        if (pointer == address(0)) {
            return 0;
        }

        // checked math will underflow if pointer.code.length == 0
        return (pointer.code.length - 1) / 20;
    }

    /// treat the data at pointer as a 1-indexed array of addresses
    /// @dev the caller is responsible for ensuring that the pointer is valid and that the index is in bounds
    function fetch(address pointer, uint256 index) internal view returns (address) {
        require(index > 0, "ZERO_ID");
        unchecked {
            uint256 end = index * 20;
            return bytesToAddress(SSTORE2.read(pointer, end - 20, end));
        }
    }

    function bytesToAddress(bytes memory b) internal pure returns (address payable a) {
        require(b.length == 20);
        assembly {
            a := shr(96, mload(add(b, 32)))
        }
    }

    function editionSize() external view override returns (uint256) {}

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
    ) external override {}

    function enableDefaultOperatorFilter() external override {}

    function endOfMintPeriod() external view override returns (uint256) {}

    function isApprovedMinter(address minter) external view override returns (bool) {}

    function isMintingEnded() external view override returns (bool) {}

    function setApprovedMinter(address minter, bool allowed) external override {
        approvedMinter[minter] = allowed;
    }

    function setOperatorFilter(address operatorFilter) external override {}

    function withdraw() external override {}

    function getPrimaryOwnersPointer(uint256 index) external view override returns (address) {}
}
