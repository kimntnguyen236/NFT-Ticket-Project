const EventManager = artifacts.require("EventManager");
const UserAccount = artifacts.require("UserAccount");

module.exports = function (deployer){
    deployer.deploy(EventManager, UserAccount.address);
}