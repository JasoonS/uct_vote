var SimpleStorage = artifacts.require("./SimpleStorage.sol")
var InvestecCoin = artifacts.require("./InvestecCoin.sol")


module.exports = function(deployer) {
  deployer.deploy(SimpleStorage)
  deployer.deploy(InvestecCoin)
};
