// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ShowtimeVerifier} from "src/ShowtimeVerifier.sol";
import {EditionFactory} from "src/editions/EditionFactory.sol";
import {Edition} from "nft-editions/Edition.sol";
import {MultiBatchEdition} from "nft-editions/MultiBatchEdition.sol";
import {SingleBatchEdition} from "nft-editions/SingleBatchEdition.sol";
import {console} from "forge-std/console.sol";

contract LazyVerifyerOptimism is Script {
    ShowtimeVerifier public verifier;
    EditionFactory public factory;
    Edition public edition;
    MultiBatchEdition public multiBatchEdition;
    SingleBatchEdition public singleBatchEdition;

    address public verifierOwner = 0x244312D5330DEBD654fE1F4E353baDAc730D7B3C;

    // Deployer address: 0x13B945CC6aFe41Fb3215e82ff4825819C9cA271D
    uint256 _deployerPrivateKey = vm.envUint("DEPLOYER_OPTIMISM_PRIVATE_KEY");

    function run() external {
        vm.startBroadcast(_deployerPrivateKey);
        // Deploy verifier
        verifier = new ShowtimeVerifier(verifierOwner);
        address verifierAddress = address(verifier);
        console.logAddress(verifierAddress);
        vm.stopBroadcast();
    }
}

// ➜  showtime-contracts-v2 git:(lazy-deploy-goerli-base) ✗ forge script script/LazyVerifyerOptimism.s.sol --rpc-url https://opt-goerli.g.alchemy.com/v2/6rq7HIVSRcg0-_G1xEhe-C9gxnIS2cy8 --broadcast -vvvv

// [⠊] Compiling...
// No files changed, compilation skipped
// Traces:
//   [1204337] LazyVerifyerOptimism::run() 
//     ├─ [0] VM::startBroadcast(<pk>) 
//     │   └─ ← ()
//     ├─ [1134414] → new ShowtimeVerifier@0xe195018fE32b2c5E52a9c4707BF9902f0Cbf7d6f
//     │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0x13B945CC6aFe41Fb3215e82ff4825819C9cA271D)
//     │   ├─ emit OwnershipTransferred(previousOwner: 0x13B945CC6aFe41Fb3215e82ff4825819C9cA271D, newOwner: 0x244312D5330DEBD654fE1F4E353baDAc730D7B3C)
//     │   └─ ← 5533 bytes of code
//     ├─ [0] console::log(ShowtimeVerifier: [0xe195018fE32b2c5E52a9c4707BF9902f0Cbf7d6f]) [staticcall]
//     │   └─ ← ()
//     ├─ [0] VM::stopBroadcast() 
//     │   └─ ← ()
//     └─ ← ()


// Script ran successfully.

// == Logs ==
//   0xe195018fE32b2c5E52a9c4707BF9902f0Cbf7d6f

// EIP-3855 is not supported in one or more of the RPCs used.
// Unsupported Chain IDs: 420.
// Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
// For more information, please see https://eips.ethereum.org/EIPS/eip-3855

// ## Setting up (1) EVMs.
// ==========================
// Simulated On-chain Traces:

//   [1276478] → new ShowtimeVerifier@0xe195018fE32b2c5E52a9c4707BF9902f0Cbf7d6f
//     ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0x13B945CC6aFe41Fb3215e82ff4825819C9cA271D)
//     ├─ emit OwnershipTransferred(previousOwner: 0x13B945CC6aFe41Fb3215e82ff4825819C9cA271D, newOwner: 0x244312D5330DEBD654fE1F4E353baDAc730D7B3C)
//     └─ ← 5533 bytes of code


// ==========================

// Chain 420

// Estimated gas price: 3.0000001 gwei

// Estimated total gas used for script: 1659421

// Estimated amount required: 0.0049782631659421 ETH

// ==========================

// ###
// Finding wallets for all the necessary addresses...
// ##
// Sending transactions [0 - 0].
// ⠁ [00:00:00] [###################################################################################################################################################################] 1/1 txes (0.0s)
// Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/LazyVerifyerOptimism.s.sol/420/run-latest.json

// Sensitive values saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/cache/LazyVerifyerOptimism.s.sol/420/run-latest.json

// ##
// Waiting for receipts.
// ⠉ [00:00:07] [###############################################################################################################################################################] 1/1 receipts (0.0s)
// ##### optimism-goerli
// ✅  [Success]Hash: 0x0b8410c49cb99e3a996ca5b0077801a17cf6800b92498ae1c10c54ce52afeaaa
// Contract Address: 0xe195018fE32b2c5E52a9c4707BF9902f0Cbf7d6f
// Block: 16163702
// Paid: 0.0038294340638239 ETH (1276478 gas * 3.00000005 gwei)


// Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/LazyVerifyerOptimism.s.sol/420/run-latest.json

// Sensitive values saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/cache/LazyVerifyerOptimism.s.sol/420/run-latest.json



// ==========================

// ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
// Total Paid: 0.0038294340638239 ETH (1276478 gas * avg 3.00000005 gwei)

// Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/LazyVerifyerOptimism.s.sol/420/run-latest.json

// Sensitive values saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/cache/LazyVerifyerOptimism.s.sol/420/run-latest.json