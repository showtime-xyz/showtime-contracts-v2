// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Test, console2} from "forge-std/Test.sol";

import {SingleBatchEdition} from "nft-editions/SingleBatchEdition.sol";

import {Attestation, SignedAttestation} from "src/interfaces/IShowtimeVerifier.sol";
import {EditionFactory, EditionData} from "src/editions/EditionFactory.sol";
import {ShowtimeVerifier} from "src/ShowtimeVerifier.sol";

import {ShowtimeVerifierFixture} from "test/fixtures/ShowtimeVerifierFixture.sol";

library EditionDataWither {
    function withEditionImpl(EditionData memory self, address editionImpl) internal pure returns (EditionData memory) {
        self.editionImpl = editionImpl;
        return self;
    }

    function withCreatorAddr(EditionData memory self, address creatorAddr) internal pure returns (EditionData memory) {
        self.creatorAddr = creatorAddr;
        return self;
    }

    function withMinterAddr(EditionData memory self, address minterAddr) internal pure returns (EditionData memory) {
        self.minterAddr = minterAddr;
        return self;
    }

    function withName(EditionData memory self, string memory name) internal pure returns (EditionData memory) {
        self.name = name;
        return self;
    }

    function withDescription(EditionData memory self, string memory description)
        internal
        pure
        returns (EditionData memory)
    {
        self.description = description;
        return self;
    }

    function withAnimationUrl(EditionData memory self, string memory animationUrl)
        internal
        pure
        returns (EditionData memory)
    {
        self.animationUrl = animationUrl;
        return self;
    }

    function withImageUrl(EditionData memory self, string memory imageUrl) internal pure returns (EditionData memory) {
        self.imageUrl = imageUrl;
        return self;
    }

    function withEditionSize(EditionData memory self, uint256 editionSize) internal pure returns (EditionData memory) {
        self.editionSize = editionSize;
        return self;
    }

    function withMintPeriodSeconds(EditionData memory self, uint256 mintPeriodSeconds)
        internal
        pure
        returns (EditionData memory)
    {
        self.mintPeriodSeconds = mintPeriodSeconds;
        return self;
    }

    function withOperatorFilter(EditionData memory self, address operatorFilter)
        internal
        pure
        returns (EditionData memory)
    {
        self.operatorFilter = operatorFilter;
        return self;
    }
}

contract EditionFactoryFixture is Test, ShowtimeVerifierFixture {
    uint256 internal constant ROYALTY_BPS = 1000;
    uint256 internal constant BATCH_SIZE = 1228;

    address internal immutable SINGLE_BATCH_EDITION_IMPL = address(new SingleBatchEdition());
    EditionData internal DEFAULT_EDITION_DATA;

    EditionFactory internal editionFactory;

    address creator = makeAddr("creator");
    address relayer = makeAddr("relayer");

    function __EditionFactoryFixture_setUp() internal {
        __ShowtimeVerifierFixture_setUp();

        // configure editionFactory
        editionFactory = new EditionFactory(address(verifier));

        // configure default edition data
        DEFAULT_EDITION_DATA = EditionData({
            editionImpl: SINGLE_BATCH_EDITION_IMPL,
            creatorAddr: creator,
            minterAddr: address(editionFactory),
            name: "name",
            description: "description",
            animationUrl: "animationUrl",
            imageUrl: "imageUrl",
            editionSize: 0,
            royaltiesBPS: ROYALTY_BPS,
            mintPeriodSeconds: 0,
            externalUrl: "externalUrl",
            creatorName: "creatorName",
            tags: "tag1,tag2",
            operatorFilter: address(0)
        });
    }

    /// @dev takes care of pranking the relayer
    function createWithBatch(
        EditionData memory editionData,
        SignedAttestation memory signedAttestation,
        bytes memory recipients,
        bytes memory expectedError
    ) public returns (address newEdition) {
        // the attestation is bound to a specific relayer
        vm.prank(relayer);

        if (expectedError.length > 0) {
            vm.expectRevert(expectedError);
        }

        newEdition = editionFactory.createWithBatch(editionData, recipients, signedAttestation);
    }

    function createWithBatch(bytes memory recipients) public returns (address newEdition) {
        return createWithBatch(DEFAULT_EDITION_DATA, signed(signerKey, getAttestation()), recipients, "");
    }

    /// @dev takes care of pranking the relayer
    function create(
        EditionData memory editionData,
        SignedAttestation memory signedAttestation,
        bytes memory expectedError
    ) public returns (address newEdition) {
        // the attestation is bound to a specific relayer
        vm.prank(relayer);

        if (expectedError.length > 0) {
            vm.expectRevert(expectedError);
        }

        newEdition = editionFactory.create(editionData, signedAttestation);
    }

    function create(EditionData memory editionData) public returns (address newEdition) {
        return create(editionData, signed(signerKey, getAttestation(editionData)), "");
    }

    function create() public returns (address newEdition) {
        return create(DEFAULT_EDITION_DATA, signed(signerKey, getAttestation()), "");
    }

    function mintBatch(address edition, bytes memory recipients, bytes memory expectedError) public returns (uint256) {
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation(edition, relayer));

        if (expectedError.length > 0) {
            vm.expectRevert(expectedError);
        }

        // the attestation is bound to a specific relayer
        vm.prank(relayer);
        return editionFactory.mintBatch(edition, recipients, signedAttestation);
    }

    function mint(address edition, address to) public returns (uint256 tokenId) {
        return mint(edition, to, "");
    }

    function mint(address edition, address to, bytes memory expectedError) public returns (uint256 tokenId) {
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation(edition, relayer));

        if (expectedError.length > 0) {
            vm.expectRevert(expectedError);
        }

        // the attestation is bound to a specific relayer
        vm.prank(relayer);
        tokenId = editionFactory.mint(edition, to, signedAttestation);
    }

    /// attestation for the default edition and the default relayer
    function getAttestation() public view returns (Attestation memory) {
        return getAttestation(DEFAULT_EDITION_DATA);
    }

    /// predict the edition address from the edition data and assume the sender is the relayer
    function getAttestation(EditionData memory editionData)
        public
        view
        returns (Attestation memory creatorAttestation)
    {
        uint256 editionId = getEditionId(editionData);
        address editionAddr = getExpectedEditionAddr(editionData.editionImpl, editionId);
        return getAttestation(editionAddr, relayer);
    }

    function getAttestation(address editionAddr, address msgSender)
        public
        view
        returns (Attestation memory creatorAttestation)
    {
        creatorAttestation = Attestation({
            context: getExpectedContext(),
            beneficiary: getBeneficiary(editionAddr, msgSender),
            validUntil: block.timestamp + 2 minutes,
            nonce: verifier.nonces(msgSender)
        });
    }

    function getExpectedContext() public view returns (address) {
        return address(editionFactory);
    }

    function getEditionId(EditionData memory editionData) public view returns (uint256) {
        return editionFactory.getEditionId(editionData);
    }

    function getEditionId() public view returns (uint256) {
        return getEditionId(DEFAULT_EDITION_DATA);
    }

    function getExpectedEditionAddr(address editionImpl, uint256 editionId) public view returns (address) {
        return address(editionFactory.getEditionAtId(editionImpl, editionId));
    }

    function getExpectedEditionAddr() public view returns (address) {
        return getExpectedEditionAddr(SINGLE_BATCH_EDITION_IMPL, getEditionId());
    }

    function getBeneficiary(address edition, address msgSender) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(edition, msgSender)))));
    }

    function getBeneficiary() public view returns (address) {
        return getBeneficiary(getExpectedEditionAddr(), relayer);
    }
}
