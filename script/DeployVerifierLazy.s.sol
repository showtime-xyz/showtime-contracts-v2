// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {ShowtimeVerifier} from "src/ShowtimeVerifier.sol";

contract ShowtimeVerifierLocalDeployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        ShowtimeVerifier verifier = new ShowtimeVerifier(deployerAddress);
        vm.stopBroadcast();
    }
}
