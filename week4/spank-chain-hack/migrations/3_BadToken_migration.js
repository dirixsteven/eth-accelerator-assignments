var BadToken = artifacts.require("BadToken.sol");

module.exports = function(deployer) {
  deployer.deploy(BadToken);
};