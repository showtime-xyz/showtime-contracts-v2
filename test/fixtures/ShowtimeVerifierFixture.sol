// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Test} from "forge-std/Test.sol";

import {Attestation, SignedAttestation} from "src/interfaces/IShowtimeVerifier.sol";
import {ShowtimeVerifier} from "src/ShowtimeVerifier.sol";

contract ShowtimeVerifierFixture is Test {
    ShowtimeVerifier internal verifier;
    address internal verifierOwner;
    address internal signerAddr;
    uint256 internal signerKey;

    function __ShowtimeVerifierFixture_setUp() internal {
        // configure verifier
        verifierOwner = makeAddr("verifierOwner");
        verifier = new ShowtimeVerifier(verifierOwner);
        (signerAddr, signerKey) = makeAddrAndKey("signer");

        vm.prank(verifierOwner);
        verifier.registerSigner(signerAddr, 7);
    }

    function digest(Attestation memory _attestation) public view returns (bytes32) {
        bytes memory encodedStruct = verifier.encode(_attestation);
        bytes32 structHash = keccak256(abi.encodePacked(verifier.REQUEST_TYPE_HASH(), encodedStruct));
        return keccak256(abi.encodePacked("\x19\x01", verifier.domainSeparator(), structHash));
    }

    function sign(uint256 key, Attestation memory someAttestation) public view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest(someAttestation));
        return abi.encodePacked(r, s, v);
    }

    function signed(uint256 key, Attestation memory someAttestation) public view returns (SignedAttestation memory) {
        return SignedAttestation({attestation: someAttestation, signature: sign(key, someAttestation)});
    }

    /// @dev signs an attestation with the default signer key
    function signed(Attestation memory someAttestation) public view returns (SignedAttestation memory) {
        return signed(signerKey, someAttestation);
    }
}
