// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./common/Deployer.s.sol";

import {ShowtimeVerifier} from "src/ShowtimeVerifier.sol";

contract ShowtimeVerifierDeployer is Deployer {
    address constant SHOWTIME_MULTISIG_POLYGON = 0x8C929a803A5Aae8B0F8fB9df0217332cBD7C6cB5;
    address constant OWNER_POLYGON = SHOWTIME_MULTISIG_POLYGON;
    address constant OWNER_MUMBAI = 0x515F7d84cEE53051b7ADF645fA2220f65BC25c68;

    function contractName() public pure override returns (string memory) {
        return "ShowtimeVerifier";
    }

    function __deploy(uint256 deployerPK) public override returns (address) {
        address owner = block.chainid == 137 ? OWNER_POLYGON : OWNER_MUMBAI;

        vm.broadcast(deployerPK);
        return address(new ShowtimeVerifier(owner));
    }
}
