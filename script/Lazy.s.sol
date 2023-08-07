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
    address public verifierAddress = 0xd0Dcc4d9E99cc9d368abD2E40aD95293f891baa5;
    ShowtimeVerifier public verifier = ShowtimeVerifier(verifierAddress);
    EditionFactory public factory;
    Edition public edition;
    MultiBatchEdition public multiBatchEdition;
    SingleBatchEdition public singleBatchEdition;

    address public verifierManager;
    uint256 public val;

    // Deployer address: 0x7D4bd39B26AE7D6Bf696aD2250D89Ab5b5D43f74
    uint256 _deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

    function run() external {
        // Call verifier view function
        verifierManager = verifier.manager();
        val = verifier.MAX_ATTESTATION_VALIDITY_SECONDS();
        console.logUint(val);

        vm.startBroadcast(_deployerPrivateKey);
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

/*
Ran with `forge script script/Lazy.s.sol --rpc-url https://goerli.base.org  -vvvv`
Logs:
Compiler run successful
Traces:
  [14236404] ShowtimeVerifierLocalDeployer::run() 
    ├─ [2393] 0xd0Dcc4d9E99cc9d368abD2E40aD95293f891baa5::manager() [staticcall]
    │   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000000
    ├─ [215] 0xd0Dcc4d9E99cc9d368abD2E40aD95293f891baa5::MAX_ATTESTATION_VALIDITY_SECONDS() [staticcall]
    │   └─ ← 0x000000000000000000000000000000000000000000000000000000000000012c
    ├─ [0] console::f5b1bba9(000000000000000000000000000000000000000000000000000000000000012c) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::startBroadcast(<pk>) 
    │   └─ ← ()
    ├─ [1165454] → new EditionFactory@0x966a22b5196413f350859f176EA139a2658c5A8c
    │   └─ ← 5820 bytes of code
    ├─ [4141237] → new Edition@0x4725e6Ba29c07e5309Cbd0500951E4AF55174bf4
    │   ├─ emit Initialized()
    │   └─ ← 20542 bytes of code
    ├─ [4368146] → new MultiBatchEdition@0x9a658444Ac22845E17407112f95757396da8D141
    │   ├─ emit Initialized()
    │   └─ ← 21675 bytes of code
    ├─ [4270846] → new SingleBatchEdition@0xC4D76011cb1bCad3A73a325C14Ff56E51fb64D4f
    │   ├─ emit Initialized()
    │   └─ ← 21178 bytes of code
    ├─ [0] VM::stopBroadcast() 
    │   └─ ← ()
    └─ ← ()


Script ran successfully.

== Logs ==
  300

## Setting up (1) EVMs.
==========================
Simulated On-chain Traces:

  [1305338] → new EditionFactory@0x966a22b5196413f350859f176EA139a2658c5A8c
    └─ ← 5820 bytes of code

  [4505545] → new Edition@0x4725e6Ba29c07e5309Cbd0500951E4AF55174bf4
    ├─ emit Initialized()
    └─ ← 20542 bytes of code

  [4752262] → new MultiBatchEdition@0x9a658444Ac22845E17407112f95757396da8D141
    ├─ emit Initialized()
    └─ ← 21675 bytes of code

  [4647306] → new SingleBatchEdition@0xC4D76011cb1bCad3A73a325C14Ff56E51fb64D4f
    ├─ emit Initialized()
    └─ ← 21178 bytes of code


==========================

Chain 84531

Estimated gas price: 3.000000104 gwei

Estimated total gas used for script: 19773584

Estimated amount required: 0.059320754056452736 ETH

==========================

SIMULATION COMPLETE. To broadcast these transactions, add --broadcast and wallet configuration(s) to the previous command. See forge script --help for more.

Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/Lazy.s.sol/84531/dry-run/run-latest.json

➜  showtime-contracts-v2 git:(main) ✗ forge script script/Lazy.s.sol --rpc-url https://goerli.base.org --broadcast  -vvvv
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [14236404] ShowtimeVerifierLocalDeployer::run() 
    ├─ [2393] 0xd0Dcc4d9E99cc9d368abD2E40aD95293f891baa5::manager() [staticcall]
    │   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000000
    ├─ [215] 0xd0Dcc4d9E99cc9d368abD2E40aD95293f891baa5::MAX_ATTESTATION_VALIDITY_SECONDS() [staticcall]
    │   └─ ← 0x000000000000000000000000000000000000000000000000000000000000012c
    ├─ [0] console::f5b1bba9(000000000000000000000000000000000000000000000000000000000000012c) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::startBroadcast(<pk>) 
    │   └─ ← ()
    ├─ [1165454] → new EditionFactory@0x966a22b5196413f350859f176EA139a2658c5A8c
    │   └─ ← 5820 bytes of code
    ├─ [4141237] → new Edition@0x4725e6Ba29c07e5309Cbd0500951E4AF55174bf4
    │   ├─ emit Initialized()
    │   └─ ← 20542 bytes of code
    ├─ [4368146] → new MultiBatchEdition@0x9a658444Ac22845E17407112f95757396da8D141
    │   ├─ emit Initialized()
    │   └─ ← 21675 bytes of code
    ├─ [4270846] → new SingleBatchEdition@0xC4D76011cb1bCad3A73a325C14Ff56E51fb64D4f
    │   ├─ emit Initialized()
    │   └─ ← 21178 bytes of code
    ├─ [0] VM::stopBroadcast() 
    │   └─ ← ()
    └─ ← ()


Script ran successfully.

== Logs ==
  300

## Setting up (1) EVMs.
==========================
Simulated On-chain Traces:

  [1305338] → new EditionFactory@0x966a22b5196413f350859f176EA139a2658c5A8c
    └─ ← 5820 bytes of code

  [4505545] → new Edition@0x4725e6Ba29c07e5309Cbd0500951E4AF55174bf4
    ├─ emit Initialized()
    └─ ← 20542 bytes of code

  [4752262] → new MultiBatchEdition@0x9a658444Ac22845E17407112f95757396da8D141
    ├─ emit Initialized()
    └─ ← 21675 bytes of code

  [4647306] → new SingleBatchEdition@0xC4D76011cb1bCad3A73a325C14Ff56E51fb64D4f
    ├─ emit Initialized()
    └─ ← 21178 bytes of code


==========================

Chain 84531

Estimated gas price: 3.0000001 gwei

Estimated total gas used for script: 19773584

Estimated amount required: 0.0593207539773584 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 3].
⠚ [00:00:00] [###############################################################################################################################################################################################################################] 4/4 txes (0.0s)
Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/Lazy.s.sol/84531/run-latest.json

##
Waiting for receipts.
⠒ [00:00:06] [###########################################################################################################################################################################################################################] 4/4 receipts (0.0s)
##### 84531
✅ Hash: 0x9f55b3b37808b81519cec3c4ae2c101203e514cf71c83d0fa75337a348ad709f
Contract Address: 0x966a22b5196413f350859f176ea139a2658c5a8c
Block: 7555840
Paid: 0.003916014066572238 ETH (1305338 gas * 3.000000051 gwei)


##### 84531
✅ Hash: 0x060f6ca9c164de4bde62f963570e97285183271dc76d46ccae38a2e5a4a3c5d4
Contract Address: 0x4725e6ba29c07e5309cbd0500951e4af55174bf4
Block: 7555840
Paid: 0.013516635229782795 ETH (4505545 gas * 3.000000051 gwei)


##### 84531
✅ Hash: 0x36febad0ec7b8074f3972b93179e277e8c504dd17b0377f8615efcd0340c3651
Contract Address: 0x9a658444ac22845e17407112f95757396da8d141
Block: 7555840
Paid: 0.014256786242365362 ETH (4752262 gas * 3.000000051 gwei)


##### 84531
✅ Hash: 0x70343980e84d897cee3c06471fda7678fb87d9ebc3f0721e403d274bf6d21775
Contract Address: 0xc4d76011cb1bcad3a73a325c14ff56e51fb64d4f
Block: 7555840
Paid: 0.013941918237012606 ETH (4647306 gas * 3.000000051 gwei)


Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/Lazy.s.sol/84531/run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.045631353775733001 ETH (15210451 gas * avg 3.000000051 gwei)

Transactions saved to: /Users/maxime/dev/showtime/showtime-contracts-v2/broadcast/Lazy.s.sol/84531/run-latest.json
*/