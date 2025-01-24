// we require the Hardhat Runtime enviornment explicitly here. This is optional but 
// useful for running the script in a standalone fashion through 'node<script>'.
// 
// 

const hre = require("hardhat");

async function main(){
    await hre.run("compile");
    // Hardhat always run the compile task when running scripts with its command 
    // line interface.
    // 
    // If this script is run directly using 'node' you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
    
    // We get the contract to deploy
    const CrowdFunding = await hre.ethers.getContractFactory("CrowdFunding");
    console.log("Deploying contract...");
    const crowdFunding = await CrowdFunding.deploy();
    console.log("Deployment result:", crowdFunding);
    console.log("CrowdFunding deployed to:", crowdFunding.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
    