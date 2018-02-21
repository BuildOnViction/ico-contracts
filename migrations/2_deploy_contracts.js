const TomoCoin = artifacts.require('TomoCoin');
const TomoContributorWhitelist = artifacts.require('TomoContributorWhitelist');
const TomoTokenSale = artifacts.require('TomoTokenSale');
const MultisigWallet = artifacts.require('MultiSigWallet.sol')

module.exports = function(deployer) {
  deployer.deploy(MultisigWallet, [
    '0xfa6FC26F897027289017bEC8279a3b4b2F3c50D4',
    '0x008455E75280F8Ab322E3c1d060CE9B1b8249a66',
    '0xfDd69f168bc87e85673A66898bf3Efb3c27c415b'
  ], 2).then(() => {
    return deployer.deploy(
      TomoCoin,
      MultisigWallet.address
    ).then(() => {
      return deployer.deploy(TomoContributorWhitelist);
    }).then(() => {
      return deployer.deploy(
        TomoTokenSale,
        TomoCoin.address,
        TomoContributorWhitelist.address,
        MultisigWallet.address,
        MultisigWallet.address
      ).then(() => {
        return TomoCoin.deployed().then(function(instance) {
          return instance.setTokenSaleAddress(TomoTokenSale.address);
        });
      });
    });
  }).catch(e => console.log(e));
};
