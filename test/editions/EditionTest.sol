// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/forge-std/src/Test.sol";
import "nft-editions/interfaces/Errors.sol";

import {EditionFactory, EditionData} from "src/editions/EditionFactory.sol";
import {EditionFactoryFixture, EditionDataWither} from "test/fixtures/EditionFactoryFixture.sol";
import {IEdition} from "nft-editions/interfaces/IEdition.sol";
import {Edition} from "nft-editions/Edition.sol";
import {ShowtimeVerifierFixture, Attestation, SignedAttestation} from "test/fixtures/ShowtimeVerifierFixture.sol";
import "src/editions/interfaces/Errors.sol";


contract EditionTest is Test, ShowtimeVerifierFixture, EditionFactoryFixture {
    using EditionDataWither for EditionData;

    address editionImpl;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address dennis = makeAddr("dennis");

    function setUp() public {
        __EditionFactoryFixture_setUp();

        editionImpl = address(new Edition());
    }

    function test_e2e_limitedEdition() public {
        uint256 EDITION_SIZE = 3;

        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(editionImpl).withEditionSize(EDITION_SIZE);
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation(editionData));

        vm.prank(relayer);
        address editionAddr = editionFactory.create(editionData, signedAttestation);

        Edition edition = Edition(editionAddr);

        // make sure the edition looks the way we expect
        assertEq(edition.totalSupply(), 0);
        assertEq(edition.editionSize(), EDITION_SIZE);
        assertFalse(edition.isMintingEnded());
        assertTrue(edition.isApprovedMinter(address(editionFactory)));
        assertFalse(edition.isApprovedMinter(address(this))); // not everybody is approved

        // we can mint up to the edition size
        mint(editionAddr, alice, "");
        mint(editionAddr, bob, "");
        mint(editionAddr, charlie, "");

        // we can't mint more than the edition size
        mint(editionAddr, dennis, abi.encodeWithSelector(SoldOut.selector));

        // the edition is now sold out
        assertEq(edition.totalSupply(), EDITION_SIZE);

        assertEq(edition.ownerOf(1), alice);
        assertEq(edition.ownerOf(2), bob);
        assertEq(edition.ownerOf(3), charlie);

        assertEq(edition.balanceOf(alice), 1);
        assertEq(edition.balanceOf(bob), 1);
        assertEq(edition.balanceOf(charlie), 1);
        assertEq(edition.balanceOf(dennis), 0);

        // no token ids past the edition size
        vm.expectRevert("NOT_MINTED");
        edition.ownerOf(EDITION_SIZE + 1);
    }

    function test_create_timeLimitedEdition() public {
        uint256 CLAIM_DURATION_WINDOW_SECONDS = 2 days;
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(editionImpl).withMintPeriodSeconds(CLAIM_DURATION_WINDOW_SECONDS);

        // create a new edition
        address editionAddress = create(editionData);
        IEdition edition = IEdition(editionAddress);
        assertFalse(edition.isMintingEnded());

        // warp into the future
        vm.warp(block.timestamp + CLAIM_DURATION_WINDOW_SECONDS + 1);

        assertTrue(edition.isMintingEnded());

        // can no longer mint
        mint(editionAddress, address(this), abi.encodeWithSelector(TimeLimitReached.selector));
    }

    function test_enableDefaultOperatorFilter() public {
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(editionImpl).withEnableDefaultOperatorFilter(true);

        Edition edition = Edition(create(editionData));

        assertTrue(edition.activeOperatorFilter() != address(0));
    }

    function test_disableDefaultOperatorFilter() public {
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(editionImpl).withEnableDefaultOperatorFilter(false);

        Edition edition = Edition(create(editionData));

        assertTrue(edition.activeOperatorFilter() == address(0));
    }
}
