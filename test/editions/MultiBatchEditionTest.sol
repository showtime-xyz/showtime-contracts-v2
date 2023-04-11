// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/forge-std/src/Test.sol";
import "nft-editions/interfaces/Errors.sol";

import {Addresses} from "SS2ERC721-helpers/Addresses.sol";
import {EditionFactory, EditionData} from "src/editions/EditionFactory.sol";
import {EditionFactoryFixture, EditionDataWither} from "test/fixtures/EditionFactoryFixture.sol";
import {IBatchMintable} from "nft-editions/interfaces/IBatchMintable.sol";
import {MultiBatchEditionStub} from "test/fixtures/MultiBatchEditionStub.sol";
import {ShowtimeVerifierFixture, Attestation, SignedAttestation} from "test/fixtures/ShowtimeVerifierFixture.sol";
import "src/editions/interfaces/Errors.sol";


contract MultiBatchEditionTest is Test, ShowtimeVerifierFixture, EditionFactoryFixture {
    using EditionDataWither for EditionData;

    address multiBatchImpl;

    function setUp() public {
        __EditionFactoryFixture_setUp();

        multiBatchImpl = address(new MultiBatchEditionStub());
    }

    function test_e2e_happyPath() public {
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(multiBatchImpl);
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation(editionData));

        vm.prank(relayer);
        address edition = editionFactory.create(editionData, signedAttestation);

        MultiBatchEditionStub multiBatchEdition = MultiBatchEditionStub(edition);
        multiBatchEdition.setMaxSupply(300);

        address startingAddr = address(1);

        mintBatch(edition, Addresses.make(address(uint160(startingAddr)), 100), "");
        mintBatch(edition, Addresses.make(address(uint160(startingAddr) + 100), 100), "");
        mintBatch(edition, Addresses.make(address(uint160(startingAddr) + 200), 100), "");

        assertEq(multiBatchEdition.totalSupply(), 300);

        for (uint160 i = 0; i < 300; i++) {
            assertTrue(multiBatchEdition.isPrimaryOwner(address(uint160(startingAddr) + i)));
        }

        assertFalse(multiBatchEdition.isPrimaryOwner(address(301)));
    }
}
