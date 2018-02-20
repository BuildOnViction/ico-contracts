var HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    development: {
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

