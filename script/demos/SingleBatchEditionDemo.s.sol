// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Addresses} from "SS2ERC721-helpers/Addresses.sol";

import {IEditionFactory, EditionData} from "src/editions/interfaces/IEditionFactory.sol";
import {IShowtimeVerifier, Attestation, SignedAttestation} from "src/interfaces/IShowtimeVerifier.sol";

import {EditionFactoryFixture} from "test/fixtures/EditionFactoryFixture.sol";
import {ShowtimeVerifierFixture} from "test/fixtures/ShowtimeVerifierFixture.sol";

import "script/common/DeployBase.s.sol";

contract SingleBatchEditionDemo is DeployBase, EditionFactoryFixture {
    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployerAddr = vm.addr(pk);
        info("deployer address", deployerAddr);
        vm.startBroadcast(pk);

        verifier = IShowtimeVerifier(getDeployment("ShowtimeVerifier"));
        uint256 signerValidity = verifier.signerValidity(deployerAddr);
        debug("signerValidity =", signerValidity);

        assert(signerValidity > block.timestamp);


        address factoryAddr = getDeployment("EditionFactory");
        assert(factoryAddr != address(0));
        IEditionFactory factory = IEditionFactory(factoryAddr);

        address editionImpl = getDeployment("SingleBatchEdition");
        assert(editionImpl != address(0));

        address creator = 0x9cc97852491fBB3B63c539f6C20Eb24A1c76568f;
        EditionData memory editionData = EditionData({
            // factory
            editionImpl: editionImpl,
            creatorAddr: creator,
            minterAddr: factoryAddr,

            // core metadata
            name: unicode'"She gets visions" 👁️',
            description: unicode"Playing in the background:\nKetto by Bonobo 🎶",
            animationUrl: "",
            imageUrl: "ipfs://QmSEBhh7A4JKjdRAVEwLGmfF5ckabAUnYVace9KjvyqMZj",
            editionSize: 1000,
            royaltiesBPS: 2_50,
            mintPeriodSeconds: 7 days,

            // extra metadata
            externalUrl: "https://showtime.xyz/nft/polygon/0x1D6378e337f49dA12eEf49Bd1D8de3a1720115f4/0",
            creatorName: "@AliceOnChain",
            tags: "art,limited-edition,time-limited",
            operatorFilter: address(0)
        });

        uint256 editionId = factory.getEditionId(editionData);
        address expectedEditionAddr = factory.getEditionAtId(editionImpl, editionId);
        info("expectedEditionAddr =", expectedEditionAddr);

        Attestation memory attestation = Attestation({
            context: factoryAddr,
            beneficiary: getBeneficiary(expectedEditionAddr, deployerAddr),
            validUntil: block.timestamp + 2 minutes,
            nonce: verifier.nonces(deployerAddr)
        });

        SignedAttestation memory signedAttestation = SignedAttestation({
            attestation: attestation,
            signature: sign(pk, attestation)
        });

        assert(verifier.verify(signedAttestation));
        debug(unicode"✅ signed attestation passed verification!");

        bytes memory recipients = Addresses.make(address(1), 1000);

        factory.createWithBatch(editionData, recipients, signedAttestation);
        vm.stopBroadcast();
    }
}
