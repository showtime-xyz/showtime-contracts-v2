// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {IShowtimeVerifier, SignedAttestation} from "src/interfaces/IShowtimeVerifier.sol";

/// @param editionImpl the address of the implementation contract for the edition to clone
/// @param creatorAddr the address that will be configured as the owner of the edition
/// @param minterAddr the address that will be configured as the allowed minter for the edition (0 for no minter)
/// @param name Name of the edition contract
/// @param description Description of the edition entry
/// @param animationUrl Animation url (optional) of the edition entry
/// @param imageUrl Metadata: Image url (semi-required) of the edition entry
/// @param editionSize Number of editions that can be minted in total (0 for an open edition)
/// @param royaltiesBPS royalties in basis points (1/100th of a percent)
/// @param mintPeriodSeconds duration in seconds after which editions can no longer be minted or purchased (0 to have no time limit)
/// @param externalUrl Metadata: External url (optional) of the edition entry
/// @param creatorName Metadata: Creator name (optional) of the edition entry
/// @param tags list of comma-separated tags for this edition, emitted as part of the CreatedBatchEdition event
/// @param enableDefaultOperatorFilter whether to enable the default operator filter on the edition
struct EditionData {
    // factory configuration
    address editionImpl;
    address creatorAddr;
    address minterAddr;

    // initialization data
    string name;
    string description;
    string animationUrl;
    string imageUrl;
    uint256 editionSize;
    uint256 royaltiesBPS;
    uint256 mintPeriodSeconds;

    // supplemental data
    string externalUrl;
    string creatorName;
    string tags;
    bool enableDefaultOperatorFilter;
}


interface IEditionFactory {
    /// @dev we expect tags to be a comma-separated list of strings e.g. "music,location,password"
    event CreatedEdition(
        uint256 indexed editionId, address indexed creator, address editionContractAddress, string tags
    );

    function create(EditionData calldata data, SignedAttestation calldata signedAttestation)
        external returns (address editionAddress);

    function createWithBatch(
        EditionData calldata data,
        bytes calldata packedRecipients,
        SignedAttestation calldata signedAttestation
    ) external returns (address editionAddress);

    function createWithBatch(
        EditionData calldata data,
        address pointer,
        SignedAttestation calldata signedAttestation
    ) external returns (address editionAddress);

    function mintBatch(address editionImpl, bytes calldata recipients, SignedAttestation calldata signedAttestation)
        external
        returns (uint256 numMinted);

    function mintBatch(address editionImpl, address pointer, SignedAttestation calldata signedAttestation)
        external
        returns (uint256 numMinted);

    function mint(address editionAddress, address to, SignedAttestation calldata signedAttestation) external returns (uint256 tokenId);

    function showtimeVerifier() external view returns (IShowtimeVerifier);
}
