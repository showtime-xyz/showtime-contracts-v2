// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./common/Deployer.s.sol";

import {EditionFactory} from "src/editions/EditionFactory.sol";

import {ShowtimeVerifierDeployer} from "script/ShowtimeVerifier.s.sol";

contract EditionFactoryDeployer is Deployer {
    ShowtimeVerifierDeployer public showtimeVerifierDeployer = new ShowtimeVerifierDeployer();

    function contractName() public pure override returns (string memory) {
        return "EditionFactory";
    }

    function __deploy(uint256 deployerPK) public override returns (address) {
        // resolve dependencies
        // will either load an existing deployment or create a new one
        address verifier = showtimeVerifierDeployer.deploy();

        vm.broadcast(deployerPK);
        return address(new EditionFactory{salt: 0}(verifier));
    }
}
