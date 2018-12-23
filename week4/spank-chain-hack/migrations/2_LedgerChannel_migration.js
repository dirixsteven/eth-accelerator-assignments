var LedgerChannel = artifacts.require("LedgerChannel.sol");

module.exports = function(deployer) {
  deployer.deploy(LedgerChannel);
};