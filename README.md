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
