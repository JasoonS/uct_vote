var People = artifacts.require("./People.sol");

module.exports = function(deployer) {
  deployer.deploy(People);
};
