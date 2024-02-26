import { ethers } from "hardhat";

async function main() {
  const MarkNFTMarketplace = await ethers.deployContract("MarkNFTMarketplace");

  await MarkNFTMarketplace.waitForDeployment();

  console.log(
    `MarkNFTMarketplace contract has been deployed to ${MarkNFTMarketplace.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
