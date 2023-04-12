// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {SingleBatchEdition} from "nft-editions/SingleBatchEdition.sol";
import {Addresses} from "SS2ERC721-helpers/Addresses.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import "nft-editions/interfaces/Errors.sol";
import {SSTORE2} from "solmate/utils/SSTORE2.sol";

// import {Attestation, SignedAttestation} from "src/interfaces/IShowtimeVerifier.sol";

import "test/fixtures/EditionFactoryFixture.sol";
import "src/editions/interfaces/Errors.sol";

contract SingleBatchEditionTest is Test, EditionFactoryFixture {
    using EditionDataWither for EditionData;
    using Addresses for uint256;

    event CreatedEdition(
        uint256 indexed editionId, address indexed creator, address editionContractAddress, string tags
    );

    address claimer = makeAddr("claimer");
    address badActor = makeAddr("badActor");

    address singleBatchImpl;

    function setUp() public {
        __EditionFactoryFixture_setUp();

        singleBatchImpl = address(new SingleBatchEdition());
    }

    /*//////////////////////////////////////////////////////////////
                            VERIFICATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function test_createWithBatch_happyPath() public {
        uint256 id = editionFactory.getEditionId(DEFAULT_EDITION_DATA);
        address expectedAddr = address(editionFactory.getEditionAtId(SINGLE_BATCH_EDITION_IMPL, id));

        // the edition creator emits the expected event
        vm.expectEmit(true, true, true, true);
        emit CreatedEdition(id, creator, expectedAddr, "tag1,tag2");
        SingleBatchEdition edition = SingleBatchEdition(createWithBatch(abi.encodePacked(claimer)));

        // the edition has the expected address
        assertEq(address(edition), expectedAddr);

        // the edition is owned by the creator
        assertEq(edition.owner(), creator);

        // it has the expected symbol
        assertEq(edition.symbol(), unicode"✦ SHOWTIME");

        // the creator no longer automatically receives the first token (because of the single mint mechanic)
        assertEq(edition.balanceOf(creator), 0);

        // the claimer received a token
        assertEq(edition.balanceOf(claimer), 1);
    }

    function test_createWithBatch_withWrongContext() public {
        // when we have an attestation with the wrong context
        Attestation memory creatorAttestation = getAttestation();
        address expectedAddr = creatorAttestation.context;
        creatorAttestation.context = address(this); // nonsense context

        // creating a new edition should fail
        createWithBatch(
            DEFAULT_EDITION_DATA,
            signed(signerKey, creatorAttestation),
            abi.encodePacked(claimer),
            abi.encodeWithSignature("AddressMismatch(address,address)", expectedAddr, creatorAttestation.context)
        );
    }

    function test_createWithBatch_withWrongNonce() public {
        // when we have an attestation with the wrong context
        Attestation memory creatorAttestation = getAttestation();

        uint256 badNonce = uint256(uint160(address(this)));
        creatorAttestation.nonce = badNonce;

        // creating a new edition should fail
        createWithBatch(
            DEFAULT_EDITION_DATA,
            signed(signerKey, creatorAttestation),
            abi.encodePacked(claimer),
            abi.encodeWithSignature("BadNonce(uint256,uint256)", 0, badNonce)
        );
    }

    function test_createWithBatch_canNotReuseCreatorAttestation() public {
        // first one should work
        address editionAddr = address(createWithBatch(abi.encodePacked(claimer)));

        // second one should fail
        createWithBatch(
            DEFAULT_EDITION_DATA,
            signed(signerKey, getAttestation()),
            abi.encodePacked(claimer),
            abi.encodeWithSignature("DuplicateEdition(address)", editionAddr)
        );
    }

    function test_createWithBatch_canNotHijackCreatorAttestation() public {
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation());

        // when the badActor tries to steal the attestation
        signedAttestation.attestation.beneficiary = badActor;
        EditionData memory editionData = DEFAULT_EDITION_DATA.withCreatorAddr(badActor);

        address expectedAddr =
            address(editionFactory.getEditionAtId(SINGLE_BATCH_EDITION_IMPL, editionFactory.getEditionId(editionData)));

        bytes memory errorBytes = abi.encodeWithSignature(
            "AddressMismatch(address,address)",
            getBeneficiary(expectedAddr, relayer),
            signedAttestation.attestation.beneficiary
        );

        // it does not work
        createWithBatch(editionData, signedAttestation, abi.encodePacked(claimer), errorBytes);
    }

    function test_createWithBatch_canNotMintAfterInitialMint() public {
        // first one should work
        SingleBatchEdition edition = SingleBatchEdition(createWithBatch(abi.encodePacked(claimer)));

        assertEq(edition.balanceOf(claimer), 1);

        // the factory has minting rights, so pretend to be it
        vm.prank(address(editionFactory));

        // second one should fail
        vm.expectRevert("ALREADY_MINTED");
        edition.mintBatch(abi.encodePacked(claimer));
    }

    function test_createWithBatch_emptyBatchMint() public {
        // when we mint a batch with no claimers, it fails with INVALID_ADDRESSES
        createWithBatch(DEFAULT_EDITION_DATA, signed(signerKey, getAttestation()), "", "INVALID_ADDRESSES");
    }

    function test_createWithBatch_mintWithDuplicateClaimer() public {
        // when we mint a batch with a duplicate claimer, it fails with ADDRESSES_NOT_SORTED
        createWithBatch(
            DEFAULT_EDITION_DATA,
            signed(signerKey, getAttestation()),
            abi.encodePacked(claimer, claimer),
            "ADDRESSES_NOT_SORTED"
        );
    }

    function test_createWithBatch_mintWithUniqueClaimers(uint256 n) public {
        n = bound(n, 1, 1200);

        // when we mint a batch for n unique addresses
        SingleBatchEdition edition = SingleBatchEdition(createWithBatch(Addresses.make(n)));

        // then each claimer receives the expected tokens
        for (uint256 i = 0; i < n; i++) {
            // TODO: extract the ith address
            // assertEq(edition.balanceOf(addresses[i]), 1);
        }

        // and the total supply for the edition is n
        assertEq(edition.totalSupply(), n);
    }

    function test_e2e_limitedEdition(uint256 random) public {
        uint256 EDITION_SIZE = 1000;
        uint256 randomTokenId = bound(random, 1, EDITION_SIZE);

        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(singleBatchImpl).withEditionSize(EDITION_SIZE);
        SignedAttestation memory signedAttestation = signed(signerKey, getAttestation(editionData));

        vm.prank(relayer);
        address edition = editionFactory.create(editionData, signedAttestation);

        SingleBatchEdition singleBatchEdition = SingleBatchEdition(edition);

        // make sure the edition looks the way we expect
        assertEq(singleBatchEdition.totalSupply(), 0);
        assertEq(singleBatchEdition.getPrimaryOwnersPointer(0), address(0));
        assertEq(singleBatchEdition.editionSize(), EDITION_SIZE);
        assertFalse(singleBatchEdition.isMintingEnded());
        assertTrue(singleBatchEdition.isApprovedMinter(address(editionFactory)));
        assertFalse(singleBatchEdition.isApprovedMinter(address(randomTokenId.to_addr()))); // not everybody is approved

        // we can't mint more than the edition size
        mintBatch(edition, Addresses.make(EDITION_SIZE + 1), abi.encodeWithSelector(SoldOut.selector));

        // mint single batch
        address startingAddr = address(1);
        mintBatch(edition, Addresses.make(startingAddr, EDITION_SIZE), "");

        // the edition is now sold out
        assertEq(singleBatchEdition.totalSupply(), EDITION_SIZE);

        // we expect address(N) to own token N, let's just do a random sampling
        assertEq(singleBatchEdition.ownerOf(randomTokenId), randomTokenId.to_addr());
        assertEq(singleBatchEdition.balanceOf(randomTokenId.to_addr()), 1);
        assertTrue(singleBatchEdition.isPrimaryOwner(randomTokenId.to_addr()));

        // no token ids past the edition size
        address nonTokenOwner = (EDITION_SIZE + randomTokenId).to_addr();
        assertFalse(singleBatchEdition.isPrimaryOwner(nonTokenOwner));
        assertEq(singleBatchEdition.balanceOf(nonTokenOwner), 0);

        vm.expectRevert("NOT_MINTED");
        singleBatchEdition.ownerOf(EDITION_SIZE + randomTokenId);

        // the batch is full
        address pointer = singleBatchEdition.getPrimaryOwnersPointer(0);
        assertTrue(pointer != address(0));
        assertEq(pointer.code.length, EDITION_SIZE * 20 + 1); // + 1 for the SSTORE2 data offset

        // there is no second batch
        assertTrue(singleBatchEdition.getPrimaryOwnersPointer(1) == address(0));
    }

    function test_create_timeLimitedEdition() public {
        uint256 CLAIM_DURATION_WINDOW_SECONDS = 2 days;
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(singleBatchImpl).withMintPeriodSeconds(CLAIM_DURATION_WINDOW_SECONDS);

        // create a new edition
        address editionAddress = create(editionData);
        SingleBatchEdition edition = SingleBatchEdition(editionAddress);
        assertFalse(edition.isMintingEnded());

        // warp into the future
        vm.warp(block.timestamp + CLAIM_DURATION_WINDOW_SECONDS + 1);

        assertTrue(edition.isMintingEnded());

        // can no longer mint
        mintBatch(editionAddress, Addresses.make(1), abi.encodeWithSelector(TimeLimitReached.selector));
    }

    function test_createWithBatch_timeLimitedEdition() public {
        uint256 CLAIM_DURATION_WINDOW_SECONDS = 2 days;
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(singleBatchImpl).withMintPeriodSeconds(CLAIM_DURATION_WINDOW_SECONDS);

        // create a new edition
        address editionAddress = createWithBatch(editionData, signed(signerKey, getAttestation(editionData)), Addresses.make(1228), "");
        SingleBatchEdition edition = SingleBatchEdition(editionAddress);
        assertFalse(edition.isMintingEnded());

        // warp into the future
        vm.warp(block.timestamp + CLAIM_DURATION_WINDOW_SECONDS + 1);

        assertTrue(edition.isMintingEnded());

        // can no longer mint
        // but we're a single batch mint anyway
    }

    function test_enableDefaultOperatorFilter() public {
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(singleBatchImpl).withEnableDefaultOperatorFilter(true);

        SingleBatchEdition edition = SingleBatchEdition(create(editionData));

        assertTrue(edition.activeOperatorFilter() != address(0));
    }

    function test_disableDefaultOperatorFilter() public {
        EditionData memory editionData = DEFAULT_EDITION_DATA.withEditionImpl(singleBatchImpl).withEnableDefaultOperatorFilter(false);

        SingleBatchEdition edition = SingleBatchEdition(create(editionData));

        assertTrue(edition.activeOperatorFilter() == address(0));
    }
}
