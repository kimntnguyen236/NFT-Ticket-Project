const TicketNFT = artifacts.require("TicketNFT");
const UserAccount = artifacts.require("UserAccount");

module.exports = function (deployer){
    deployer.deploy(TicketNFT, UserAccount.address);
}