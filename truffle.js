var HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    tomo: {
      provider: function() {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://core.tomocoin.io');
      },
      gas: 2900000,
      network_id: 40686
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(process.env.MNEMONIC, process.env.RINKEBY);
      },
      gas: 2900000,
      network_id: 4
    }
  }
};

