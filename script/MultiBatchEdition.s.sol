// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./common/Deployer.s.sol";

import {MultiBatchEdition} from "nft-editions/MultiBatchEdition.sol";

contract MultiBatchEditionDeployer is Deployer {
    function contractName() public pure override returns (string memory) {
        return "MultiBatchEdition";
    }

    function __deploy(uint256 deployerPK) public override returns (address) {
        vm.broadcast(deployerPK);
        return address(new MultiBatchEdition());
    }
}
