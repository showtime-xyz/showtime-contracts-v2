// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./common/Deployer.s.sol";

import {SingleBatchEdition} from "nft-editions/SingleBatchEdition.sol";

/// @dev much easier to verify on Etherscan with nft-editions deploy scripts
contract SingleBatchEditionDeployer is Deployer {
    function contractName() public pure override returns (string memory) {
        return "SingleBatchEdition";
    }

    function __deploy(uint256 deployerPK) public override returns (address) {
        vm.broadcast(deployerPK);
        return address(new SingleBatchEdition());
    }
}
