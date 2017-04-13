# UCT vote

A basic voting app prototype.

UCT honours Computer Science poject by Jon Jon Clark and Jason Smythe.
Supervisors: Tommie Meyer, Christine Swart

The source of the core template is from: https://github.com/truffle-box/truffle-box-react

## Installation

1. Install truffle and an ethereum client. For local development, try EthereumJS TestRPC.
    ```javascript
    npm install -g truffle // Version 3.0.5+ required.
    npm install -g ethereumjs-testrpc
    ```

2. Clone or download the truffle box of your choice.
    ```javascript
    git clone https://github.com/JasoonS/uct_vote.git
    ```

3. Install the node dependencies.
    ```javascript
    npm install
    ```

    4. Compile and migrate the contracts. (add '-reset' to migrate if you wish to replace the contracts)
        ```javascript
        truffle compile
        truffle migrate
        ```

    5. Run the webpack server for front-end hot reloading. For now, smart contract changes must be manually recompiled and migrated.
        ```javascript
        npm run start
        ```

    6. Jest is included for testing React components and Truffle's own suite is incldued for smart contracts. Be sure you've compile your contracts before running jest, or you'll receive some file not found errors.
        ```javascript
        // Runs Jest for component tests.
        npm run test

        // Runs Truffle's test suite for smart contract tests.
        truffle test
        ```

    7. To build the application for production, use the build command. A production build will be in the build_webpack folder.
        ```javascript
        npm run build
        ```

    ## Other Commands:

    Run a local node of the Ethereum Testnet:
        ```javascript
        geth --testnet --fast --rpc --rpcapi db,eth,net,web3,personal --cache=1024  --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" --bootnodes "enode://20c9ad97c081d63397d7b685a412227a40e23c8bdc6688c6f37e97cfbc22d2b4d1db1510d8f61e6a8866ad7f0e17c02b14182d37ea7c3c8b9c2683aeb6b733a1@52.169.14.227:30303,enode://6ce05930c72abc632c58e2e4324f7c7ea478cec0ed4fa2528982cf34483094e9cbc9216e7aa349691242576d552a2a56aaeae426c5303ded677ce455ba1acd9d@13.84.180.240:30303"
        ```
