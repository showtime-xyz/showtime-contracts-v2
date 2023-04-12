// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/forge-std/src/Test.sol";
import "nft-editions/interfaces/Errors.sol";

import {Addresses} from "SS2ERC721-helpers/Addresses.sol";
import {EditionFactory, EditionData} from "src/editions/EditionFactory.sol";
import {EditionFactoryFixture, EditionDataWither} from "test/fixtures/EditionFactoryFixture.sol";
import {IBatchMintable} from "nft-editions/interfaces/IBatchMintable.sol";
import {MultiBatchEdition} from "nft-editions/MultiBatchEdition.sol";
import {ShowtimeVerifierFixture, Attestation, SignedAttestation} from "test/fixtures/ShowtimeVerifierFixture.sol";
import "src/editions/interfaces/Errors.sol";

contract MultiBatchEditionTest is Test, ShowtimeVerifierFixture, EditionFactoryFixture {
    using EditionDataWither for EditionData;
    using Addresses for uint256;

    address multiBatchImpl;

    function setUp() public {
        __EditionFactoryFixture_setUp();

        multiBatchImpl = address(new MultiBatchEdition());
    }

    function test_e2e_limitedEdition(uint256 random) public {
        uint256 EDITION_SIZE = 2000;
        uint256 randomTokenId = bound(random, 1, EDITION_SIZE);

        EditionData memory editionData =
            DEFAULT_EDITION_DATA.withEditionImpl(multiBatchImpl).withEditionSize(EDITION_SIZE);
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation(editionData));

        vm.prank(relayer);
        address edition = editionFactory.create(editionData, signedAttestation);

        MultiBatchEdition multiBatchEdition = MultiBatchEdition(edition);

        // make sure the edition looks the way we expect
        assertEq(multiBatchEdition.totalSupply(), 0);
        assertEq(multiBatchEdition.getPrimaryOwnersPointer(0), address(0));
        assertEq(multiBatchEdition.editionSize(), EDITION_SIZE);
        assertFalse(multiBatchEdition.isMintingEnded());
        assertTrue(multiBatchEdition.isApprovedMinter(address(editionFactory)));
        assertFalse(multiBatchEdition.isApprovedMinter(address(randomTokenId.to_addr()))); // not everybody is approved

        // mint in 2 batches
        address startingAddr = address(1);
        mintBatch(edition, Addresses.make(startingAddr, BATCH_SIZE), "");

        // we can't mint more than the edition size
        address nextStartingAddr = (uint160(startingAddr) + BATCH_SIZE).to_addr();
        mintBatch(edition, Addresses.make(nextStartingAddr, EDITION_SIZE), abi.encodeWithSelector(SoldOut.selector));

        // but we can mint up to the edition size
        mintBatch(edition, Addresses.make(nextStartingAddr, EDITION_SIZE - BATCH_SIZE), "");

        // the edition is now sold out
        assertEq(multiBatchEdition.totalSupply(), EDITION_SIZE);

        // we expect address(N) to own token N, let's just do a random sampling
        assertEq(multiBatchEdition.ownerOf(randomTokenId), randomTokenId.to_addr());
        assertEq(multiBatchEdition.balanceOf(randomTokenId.to_addr()), 1);
        assertTrue(multiBatchEdition.isPrimaryOwner(randomTokenId.to_addr()));

        // no token ids past the edition size
        address nonTokenOwner = (EDITION_SIZE + randomTokenId).to_addr();
        assertFalse(multiBatchEdition.isPrimaryOwner(nonTokenOwner));
        assertEq(multiBatchEdition.balanceOf(nonTokenOwner), 0);

        vm.expectRevert("NOT_MINTED");
        multiBatchEdition.ownerOf(EDITION_SIZE + randomTokenId);

        // first batch is full
        address firstBatchPointer = multiBatchEdition.getPrimaryOwnersPointer(0);
        assertTrue(firstBatchPointer != address(0));
        assertEq(firstBatchPointer.code.length, BATCH_SIZE * 20 + 1); // + 1 for the SSTORE2 data offset

        // second batch is partial
        address secondBatchPointer = multiBatchEdition.getPrimaryOwnersPointer(1);
        assertTrue(secondBatchPointer != address(0));
        assertEq(secondBatchPointer.code.length, (EDITION_SIZE - BATCH_SIZE) * 20 + 1); // + 1 for the SSTORE2 data offset

        // there is no third batch
        address thirdBatchPointer = multiBatchEdition.getPrimaryOwnersPointer(2);
        assertTrue(thirdBatchPointer == address(0));
    }

    function test_create_timeLimitedEdition() public {
        uint256 CLAIM_DURATION_WINDOW_SECONDS = 2 days;
        EditionData memory editionData =
            DEFAULT_EDITION_DATA.withEditionImpl(multiBatchImpl).withMintPeriodSeconds(CLAIM_DURATION_WINDOW_SECONDS);

        // create a new edition
        address editionAddress = create(editionData);
        MultiBatchEdition edition = MultiBatchEdition(editionAddress);
        assertFalse(edition.isMintingEnded());

        // warp into the future
        vm.warp(block.timestamp + CLAIM_DURATION_WINDOW_SECONDS + 1);

        assertTrue(edition.isMintingEnded());

        // can no longer mint
        mintBatch(editionAddress, Addresses.make(1), abi.encodeWithSelector(TimeLimitReached.selector));
    }

    function test_createWithBatch_timeLimitedEdition() public {
        uint256 CLAIM_DURATION_WINDOW_SECONDS = 2 days;
        EditionData memory editionData =
            DEFAULT_EDITION_DATA.withEditionImpl(multiBatchImpl).withMintPeriodSeconds(CLAIM_DURATION_WINDOW_SECONDS);

        // create a new edition
        address startingAddr = address(1);
        bytes memory recipients = Addresses.make(startingAddr, 1228);
        address editionAddress =
            createWithBatch(editionData, signed(signerKey, getAttestation(editionData)), recipients, "");
        MultiBatchEdition edition = MultiBatchEdition(editionAddress);
        assertFalse(edition.isMintingEnded());

        // warp into the future
        vm.warp(block.timestamp + CLAIM_DURATION_WINDOW_SECONDS + 1);

        assertTrue(edition.isMintingEnded());

        // can no longer mint
        mintBatch(editionAddress, abi.encodePacked(address(this)), abi.encodeWithSelector(TimeLimitReached.selector));
    }

    function test_enableOperatorFilter() public {
        EditionData memory editionData =
            DEFAULT_EDITION_DATA.withEditionImpl(multiBatchImpl).withOperatorFilter(address(0xc0ffee));

        MultiBatchEdition edition = MultiBatchEdition(create(editionData));

        assertEq(edition.activeOperatorFilter(), address(0xc0ffee));
    }

    function test_disableOperatorFilter() public {
        EditionData memory editionData =
            DEFAULT_EDITION_DATA.withEditionImpl(multiBatchImpl).withOperatorFilter(address(0));

        MultiBatchEdition edition = MultiBatchEdition(create(editionData));

        assertEq(edition.activeOperatorFilter(), address(0));
    }
}
