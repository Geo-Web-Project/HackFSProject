const GeoDNS = artifacts.require("GeoDNS");

module.exports = function(deployer) {
  deployer.deploy(GeoDNS);
};
