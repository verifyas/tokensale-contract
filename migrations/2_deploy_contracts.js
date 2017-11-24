//var ConvertLib = artifacts.require("./ConvertLib.sol");
//var MetaCoin = artifacts.require("./MetaCoin.sol");
var SafeMath = artifacts.require("./math/SafeMath.sol");
var CREDToken = artifacts.require("./CREDToken.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.deploy(CREDToken);
  deployer.link(CREDToken, SafeMath);

};
