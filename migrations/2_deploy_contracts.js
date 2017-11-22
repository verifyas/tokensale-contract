//var ConvertLib = artifacts.require("./ConvertLib.sol");
//var MetaCoin = artifacts.require("./MetaCoin.sol");
var SafeMath = artifacts.require("./math/SafeMath.sol");
var CREDToken = artifacts.require("./CREDToken.sol");
var UniqueAddressSet = artifacts.require("UniqueAddressSet.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.deploy(UniqueAddressSet);
  deployer.deploy(CREDToken);
  deployer.link(CREDToken, SafeMath, UniqueAddressSet);

};
