const MultiSignatureWallet = artifacts.require("MultiSignatureWallet");

module.exports = function (deployer) {
  //const owners = ["0xOwner1", "0xOwner2"]; // Replace with actual owner addresses
  const owners = ["0xe08D1a24eDCe360A5bEB831d25A134c25EE7A164"]; // Replace with actual owner addresses
  //const quorum = 2; // Set the desired quorum
  const quorum = 1; // Set the desired quorum

  deployer.deploy(MultiSignatureWallet, owners, quorum);
};
