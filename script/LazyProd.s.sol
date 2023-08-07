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

contract ShowtimeVerifierLocalDeployer is Script {
    ShowtimeVerifier public verifier;
    EditionFactory public factory;
    Edition public edition;
    MultiBatchEdition public multiBatchEdition;
    SingleBatchEdition public singleBatchEdition;

    address public verifierOwner = 0x244312D5330DEBD654fE1F4E353baDAc730D7B3C;

    // Deployer address: 0x7D4bd39B26AE7D6Bf696aD2250D89Ab5b5D43f74
    uint256 _deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

    function run() external {
        vm.startBroadcast(_deployerPrivateKey);
        // Deploy verifier
        verifier = new ShowtimeVerifier(verifierOwner);
        address verifierAddress = address(verifier);
        console.logAddress(verifierAddress);

        // Deploy EditionFactory
        factory = new EditionFactory(verifierAddress);

        // Deploy Edition
        edition = new Edition();
        // Deploy MultiBatchEdition
        multiBatchEdition = new MultiBatchEdition();
        // Deploy SingleBatchEdition
        singleBatchEdition = new SingleBatchEdition();


        vm.stopBroadcast();
    }
}

// ➜  showtime-contracts-v2 git:(lazy-deploy-goerli-base) ✗ forge script script/LazyProd.s.sol --rpc-url https://developer-access-mainnet.base.org --broadcast -vvvv
// [⠒] Compiling...
// No files changed, compilation skipped
// Traces:
  // [15381228] ShowtimeVerifierLocalDeployer::run() 
  //   ├─ [0] VM::startBroadcast(<pk>) 
  //   │   └─ ← ()
  //   ├─ [1134414] → new ShowtimeVerifier@0x481273EB2B6A21e918f6952A6c53C08691FE768F
  //   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0x7D4bd39B26AE7D6Bf696aD2250D89Ab5b5D43f74)
  //   │   ├─ emit OwnershipTransferred(previousOwner: 0x7D4bd39B26AE7D6Bf696aD2250D89Ab5b5D43f74, newOwner: 0x244312D5330DEBD654fE1F4E353baDAc730D7B3C)
  //   │   └─ ← 5533 bytes of code
  //   ├─ [0] console::log(ShowtimeVerifier: [0x481273EB2B6A21e918f6952A6c53C08691FE768F]) [staticcall]
  //   │   └─ ← ()
  //   ├─ [2393] ShowtimeVerifier::manager() [staticcall]
  //   │   └─ ← 0x0000000000000000000000000000000000000000
  //   ├─ [1165454] → new EditionFactory@0x966a22b5196413f350859f176EA139a2658c5A8c
  //   │   └─ ← 5820 bytes of code
  //   ├─ [4141237] → new Edition@0x4725e6Ba29c07e5309Cbd0500951E4AF55174bf4
  //   │   ├─ emit Initialized()
  //   │   └─ ← 20542 bytes of code
  //   ├─ [4368146] → new MultiBatchEdition@0x9a658444Ac22845E17407112f95757396da8D141
  //   │   ├─ emit Initialized()
  //   │   └─ ← 21675 bytes of code
  //   ├─ [4270846] → new SingleBatchEdition@0xC4D76011cb1bCad3A73a325C14Ff56E51fb64D4f
  //   │   ├─ emit Initialized()
  //   │   └─ ← 21178 bytes of code
  //   ├─ [0] VM::stopBroadcast() 
  //   │   └─ ← ()
  //   └─ ← ()


// Script ran successfully.

// == Logs ==
//   0x481273EB2B6A21e918f6952A6c53C08691FE768F

// ## Setting up (1) EVMs.
// ==========================
// Simulated On-chain Traces:

//   [1276478] → new ShowtimeVerifier@0x481273EB2B6A21e918f6952A6c53C08691FE768F
//     ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0x7D4bd39B26AE7D6Bf696aD2250D89Ab5b5D43f74)
//     ├─ emit OwnershipTransferred(previousOwner: 0x7D4bd39B26AE7D6Bf696aD2250D89Ab5b5D43f74, newOwner: 0x244312D5330DEBD654fE1F4E353baDAc730D7B3C)
//     └─ ← 5533 bytes of code

//   [1305338] → new EditionFactory@0x966a22b5196413f350859f176EA139a2658c5A8c
//     └─ ← 5820 bytes of code

//   [4505545] → new Edition@0x4725e6Ba29c07e5309Cbd0500951E4AF55174bf4
//     ├─ emit Initialized()
//     └─ ← 20542 bytes of code

//   [4752262] → new MultiBatchEdition@0x9a658444Ac22845E17407112f95757396da8D141
//     ├─ emit Initialized()
//     └─ ← 21675 bytes of code

//   [4647306] → new SingleBatchEdition@0xC4D76011cb1bCad3A73a325C14Ff56E51fb64D4f
//     ├─ emit Initialized()
//     └─ ← 21178 bytes of code


// ==========================

// Chain 8453

// Estimated gas price: 3.000000102 gwei

// Estimated total gas used for script: 21433005

// Estimated amount required: 0.06429901718616651 ETH

// ==========================

// ###
// Finding wallets for all the necessary addresses...
// ##
// Sending transactions [0 - 4].
// ⠒ [00:00:00] [#########################################################################################################################################################################################] 5/5 txes (0.0s)
// Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/LazyProd.s.sol/8453/run-latest.json

// ##
// Waiting for receipts.
// ⠂ [00:00:06] [#####################################################################################################################################################################################] 5/5 receipts (0.0s)
// ##### 8453
// ✅ Hash: 0x6fa8633997c6964f5e57a281b33c6d25e1243b39772c3db35ed76e9ca42445af
// Contract Address: 0x481273eb2b6a21e918f6952a6c53c08691fe768f
// Block: 2329836
// Paid: 0.003829434065100378 ETH (1276478 gas * 3.000000051 gwei)


// ##### 8453
// ✅ Hash: 0xb2de8f0d37453ec646dda3e92eb8911cf5e25e04ae90b5c33d28110f341b54d7
// Contract Address: 0x966a22b5196413f350859f176ea139a2658c5a8c
// Block: 2329836
// Paid: 0.003916014066572238 ETH (1305338 gas * 3.000000051 gwei)


// ##### 8453
// ✅ Hash: 0xbedab82c65502793f12dfb4d4876633fd9e67b16411f345460ded7d8cfc9b3b1
// Contract Address: 0x4725e6ba29c07e5309cbd0500951e4af55174bf4
// Block: 2329836
// Paid: 0.013516635229782795 ETH (4505545 gas * 3.000000051 gwei)


// ##### 8453
// ✅ Hash: 0x04e49d51788e359753b158f0b5d0d779f3128421a3be26a71d7ca6b82796d311
// Contract Address: 0x9a658444ac22845e17407112f95757396da8d141
// Block: 2329836
// Paid: 0.014256786242365362 ETH (4752262 gas * 3.000000051 gwei)


// ##### 8453
// ✅ Hash: 0x34f48827191c58e8c6ee1e4f06ca77c8776ab545566f9b926cedc5e7fc4582ca
// Contract Address: 0xc4d76011cb1bcad3a73a325c14ff56e51fb64d4f
// Block: 2329836
// Paid: 0.013941918237012606 ETH (4647306 gas * 3.000000051 gwei)


// Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/LazyProd.s.sol/8453/run-latest.json



// ==========================

// ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
// Total Paid: 0.049460787840833379 ETH (16486929 gas * avg 3.000000051 gwei)

// Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/LazyProd.s.sol/8453/run-latest.json
