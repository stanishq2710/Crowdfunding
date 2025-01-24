require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require('dotenv').config();

task("accounts", "Prints the list of accounts", async (taskArgs , hre) =>{
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts){
    console.log(account.address);
  }
})

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks:{
    sepolia:{
      url: process.env.SEPOLIA_RPC || "",
      accounts: process.env.PRIVATE_KEY !==undefined ?[process.env.PRIVATE_KEY]:[]
    }
  },
  etherscan:{
    apiKey:process.env.ETHERSCAN_API_KEY
  }

};
