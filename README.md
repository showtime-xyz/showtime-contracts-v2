# Showtime Contracts v2

This repository contains the Solidity smart contracts for the 2023 version of Showtime:

```
src
├── ShowtimeVerifier.sol -- verifies that transactions are coming from the trusted showtime.xyz backend
├── editions
│   ├── EditionFactory.sol -- interfaces with ShowtimeVerifier and deploys contracts from showtime-xyz/nft-editions
│   └── interfaces
│       ├── Errors.sol
│       └── IEditionFactory.sol
└── interfaces
    └── IShowtimeVerifier.sol
```

## Getting started

You will need to [install Foundry](https://book.getfoundry.sh/getting-started/installation).

Then clone this repository and just build and test:

```sh
forge build
forge test
```

## Deploy

```sh
# say you want to deploy ${CONTRACT}

# provision a new deployer
cast wallet new

# save the private in .env (PRIVATE_KEY=...)
# fund the deployer address

# perform a local simulation
forge script script/${CONTRACT}.s.sol

# perform a simulation against a network
forge script script/${CONTRACT}.s.sol --rpc-url <network>

# actually perform the deployment
SAVE_DEPLOYMENTS=1 forge script script/${CONTRACT}.s.sol --ffi --rpc-url <network> --broadcast --verify --watch

# optionally verify the contract as a separate step
forge verify-contract 0xA17f8d960B5a7A42174847213f3C5c19a7ef9dFd SingleBatchEdition --chain <network> --watch
```
