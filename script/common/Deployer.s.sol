// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {DeployBase} from "./DeployBase.s.sol";

abstract contract Deployer is Script, DeployBase {
    /// will first try to load an existing deployment from deployments/<network>/<contract>.json
    /// if OVERRIDE_DEPLOYMENT is set or if no deployment is found:
    /// - read PRIVATE_KEY from the environment
    /// - invoke __deploy() with the private key
    /// - save the deployment to deployments/<network>/<contract>.json
    function deploy() public virtual returns (address deployedAddr) {
        address existingAddr = getDeployment(contractName());
        bool overrideDeployment = vm.envOr("OVERRIDE_DEPLOYMENT", uint256(0)) > 0;

        if (!overrideDeployment && existingAddr != address(0)) {
            debug(string.concat("found existing ", contractName(), " deployment at"), existingAddr);
            debug("(override with env var OVERRIDE_DEPLOYMENT=1)");
            return existingAddr;
        }

        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);
        info(string.concat(unicode"deploying \n\t📜 ", contractName(), unicode"\n\t⚡️ on ", chainAlias(), unicode"\n\t📬 from deployer address"), deployer);

        deployedAddr = __deploy(pk);

        info(string.concat(unicode"✅ ", contractName(), " deployed at"), deployedAddr);
        saveDeployment(contractName(), deployedAddr);
    }

    function run() public virtual {
        deploy();
    }

    /// override this with the name of the contract that this script deploys
    function contractName() public view virtual returns (string memory);

    /// override this with the actual deployment logic, no need to worry about:
    /// - existing deployments
    /// - loading private keys
    /// - saving the deployment
    /// - logging
    ///
    /// just broadcast and deploy!
    function __deploy(uint256 deployerPrivateKey) public virtual returns (address);
}
