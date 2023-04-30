const Web3 = require("web3");
const web3 = new Web3();
const originalOutputBlockFormatter = web3.eth.getBlock.method.outputFormatter;
web3.eth.getBlock.method.outputFormatter = function(block) {
  if (typeof block.gasLimit === "string") {
    block.gasLimit = Number.parseInt(block.gasLimit, 16);
  }
  return originalOutputBlockFormatter(block);
};

const HDWalletProvider = require('@truffle/hdwallet-provider');
const infuraProjectId = 'cdd9a03e77054d4093957ba3cb3d0cc3';
const mnemonic = 'pull lucky unfair swing option sleep dragon scout wrap fortune media danger';

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    sepolia: {
      provider: () => {
        return new HDWalletProvider(mnemonic, `wss://sepolia.infura.io/ws/v3/${infuraProjectId}`);
      },
      network_id: 11155111,
      confirmations: 2,
      timeoutBlocks: 300,
      skipDryRun: true,
      gas: "30000000",
      gasPrice: 10000000000,
      deploymentPollingInterval: 30000,
      networkCheckTimeout: 100000,
    }    
  },

  mocha: {},

  compilers: {
    solc: {
      version: "0.8.19",
    }
  },
};

// goerli: {
    //   provider: () => {
    //     return new HDWalletProvider(mnemonic, `wss://goerli.infura.io/ws/v3/${infuraProjectId}`);
    //   },
    //   network_id: 5, // Goerli testnet's network ID is 5
    //   confirmations: 2,
    //   timeoutBlocks: 300,
    //   skipDryRun: true,
    //   gas: "30000000",
    //   gasPrice: 10000000000, // 10 Gwei
    //   deploymentPollingInterval: 30000,
    //   networkCheckTimeout: 100000,
    // }