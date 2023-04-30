const UserAccount = artifacts.require("UserAccount");

module.exports = function (deployer){
    deployer.deploy(UserAccount);
};