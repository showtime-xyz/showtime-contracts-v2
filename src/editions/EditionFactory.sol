// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ClonesUpgradeable} from "@openzeppelin-contracts-upgradeable/proxy/ClonesUpgradeable.sol";

import {IBatchMintable} from "nft-editions/interfaces/IBatchMintable.sol";
import {IEdition} from "nft-editions/interfaces/IEdition.sol";

import {EditionData, IEditionFactory} from "src/editions/interfaces/IEditionFactory.sol";
import {IShowtimeVerifier, Attestation, SignedAttestation} from "src/interfaces/IShowtimeVerifier.sol";

import "./interfaces/Errors.sol";

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract EditionFactory is IEditionFactory {
    string internal constant SYMBOL = unicode"✦ SHOWTIME";

    IShowtimeVerifier public immutable showtimeVerifier;

    constructor(address _showtimeVerifier) {
        showtimeVerifier = IShowtimeVerifier(_showtimeVerifier);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// Create a new batch edition contract with a deterministic address, with delayed batch minting
    /// @param signedAttestation a signed message from Showtime authorizing this action on behalf of the edition creator
    /// @return editionAddress the address of the created edition
    function create(EditionData calldata data, SignedAttestation calldata signedAttestation)
        public
        returns (address editionAddress)
    {
        editionAddress = _createEdition(data, signedAttestation);

        // we don't mint at this stage, we expect subsequent calls to `mintBatch`
    }

    /// Create and mint a new batch edition contract with a deterministic address
    /// @param packedRecipients an abi.encodePacked() array of recipient addresses for the batch mint
    /// @param signedAttestation a signed message from Showtime authorizing this action on behalf of the edition creator
    /// @return editionAddress the address of the created edition
    function createWithBatch(
        EditionData calldata data,
        bytes calldata packedRecipients,
        SignedAttestation calldata signedAttestation
    ) external override returns (address editionAddress) {
        // this will revert if the attestation is invalid
        editionAddress = _createEdition(data, signedAttestation);

        // mint a batch, using a direct list of recipients
        IBatchMintable(editionAddress).mintBatch(packedRecipients);
    }

    /// Create and mint a new batch edition contract with a deterministic address
    /// @param pointer the address of the SSTORE2 pointer with the recipients of the batch mint for this edition
    /// @param signedAttestation a signed message from Showtime authorizing this action on behalf of the edition creator
    /// @return editionAddress the address of the created edition
    function createWithBatch(EditionData calldata data, address pointer, SignedAttestation calldata signedAttestation)
        external
        override
        returns (address editionAddress)
    {
        // this will revert if the attestation is invalid
        editionAddress = _createEdition(data, signedAttestation);

        // mint a batch, using an SSTORE2 pointer
        IBatchMintable(editionAddress).mintBatch(pointer);
    }

    function mintBatch(address editionAddress, address pointer, SignedAttestation calldata signedAttestation)
        external
        override
        returns (uint256 numMinted)
    {
        validateAttestation(signedAttestation, editionAddress, msg.sender);

        return IBatchMintable(editionAddress).mintBatch(pointer);
    }

    function mintBatch(
        address editionAddress,
        bytes calldata packedRecipients,
        SignedAttestation calldata signedAttestation
    ) external override returns (uint256 numMinted) {
        validateAttestation(signedAttestation, editionAddress, msg.sender);

        return IBatchMintable(editionAddress).mintBatch(packedRecipients);
    }

    /// do a single real time mint
    function mint(address editionAddress, address to, SignedAttestation calldata signedAttestation)
        external
        override
        returns (uint256 tokenId)
    {
        validateAttestation(signedAttestation, editionAddress, msg.sender);

        return IEdition(editionAddress).mint(to);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev we expect the signed attestation's context to correspond to the address of this contract (EditionFactory)
    /// @dev we expect the signed attestation's beneficiary to be the lowest 160 bits of hash(edition || relayer)
    /// @dev note: this function does _not_ burn the nonce for the attestation
    function validateAttestation(SignedAttestation calldata signedAttestation, address edition, address relayer)
        public
        view
        returns (bool)
    {
        // verify that the context is valid
        address context = signedAttestation.attestation.context;
        address expectedContext = address(this);
        if (context != expectedContext) {
            revert AddressMismatch({expected: expectedContext, actual: context});
        }

        // verify that the beneficiary is valid
        address expectedBeneficiary = address(uint160(uint256(keccak256(abi.encodePacked(edition, relayer)))));
        address beneficiary = signedAttestation.attestation.beneficiary;
        if (beneficiary != expectedBeneficiary) {
            revert AddressMismatch({expected: expectedBeneficiary, actual: beneficiary});
        }

        // verify the signature _without_ burning
        // important: it's up to the clients of this function to make sure that the attestation can not be reused
        // for example:
        // - trying to deploy to an existing edition address will revert
        // - trying to deploy the same batch twice should revert
        if (!showtimeVerifier.verify(signedAttestation)) {
            revert VerificationFailed();
        }

        return true;
    }

    function getEditionId(EditionData calldata data) public pure returns (uint256 editionId) {
        return uint256(keccak256(abi.encodePacked(data.creatorAddr, data.name, data.animationUrl, data.imageUrl)));
    }

    function getEditionAtId(address editionImpl, uint256 editionId) public view returns (address) {
        if (editionImpl == address(0)) {
            revert NullAddress();
        }

        return ClonesUpgradeable.predictDeterministicAddress(editionImpl, bytes32(editionId), address(this));
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _createEdition(EditionData calldata data, SignedAttestation calldata signedAttestation)
        internal
        returns (address editionAddress)
    {
        uint256 editionId = getEditionId(data);
        address editionImpl = data.editionImpl;

        // we expect this to revert if editionImpl is null
        address predicted = address(getEditionAtId(editionImpl, editionId));
        validateAttestation(signedAttestation, predicted, msg.sender);

        // avoid burning all available gas if an edition already exists at this address
        if (predicted.code.length > 0) {
            revert DuplicateEdition(predicted);
        }

        // create the edition
        editionAddress = ClonesUpgradeable.cloneDeterministic(editionImpl, bytes32(editionId));
        IEdition edition = IEdition(editionAddress);

        // initialize it
        try edition.initialize(
            address(this), // owner
            data.name,
            SYMBOL,
            data.description,
            data.animationUrl,
            data.imageUrl,
            data.editionSize,
            data.royaltiesBPS,
            data.mintPeriodSeconds
        ) {
            // nothing to do
        } catch {
            // rethrow the problematic way until we have a better way
            // see https://github.com/ethereum/solidity/issues/12654
            assembly ("memory-safe") {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        emit CreatedEdition(editionId, data.creatorAddr, editionAddress, data.tags);

        // set the creator name
        string memory creatorName = data.creatorName;
        if (bytes(creatorName).length > 0) {
            string[] memory propertyNames = new string[](1);
            propertyNames[0] = "Creator";

            string[] memory propertyValues = new string[](1);
            propertyValues[0] = data.creatorName;

            edition.setStringProperties(propertyNames, propertyValues);
        }

        // set the external url
        string memory externalUrl = data.externalUrl;
        if (bytes(externalUrl).length > 0) {
            edition.setExternalUrl(data.externalUrl);
        }

        // configure the minter
        address minterAddr = data.minterAddr;
        if (minterAddr != address(0)) {
            edition.setApprovedMinter(minterAddr, true);
        }

        // configure the operator filter
        address operatorFilter = data.operatorFilter;
        if (operatorFilter != address(0)) {
            edition.setOperatorFilter(operatorFilter);
        }

        // and finally transfer ownership of the configured contract to the actual creator
        IOwnable(editionAddress).transferOwnership(data.creatorAddr);
    }
}
