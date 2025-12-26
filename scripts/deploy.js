async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Election = await ethers.getContractFactory("ScientificClubElection");
  const election = await Election.deploy();

  await election.deployed();

  console.log("ScientificClubElection deployed to:", election.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
