// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./common/Deployer.s.sol";

import {Edition} from "nft-editions/Edition.sol";

/// @dev much easier to verify on Etherscan with nft-editions deploy scripts
contract EditionDeployer is Deployer {
    function contractName() public pure override returns (string memory) {
        return "Edition";
    }

    function __deploy(uint256 deployerPK) public override returns (address) {
        vm.broadcast(deployerPK);
        return address(new Edition());
    }
}
