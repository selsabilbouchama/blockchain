const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const Election = await ethers.getContractFactory("ScientificClubElection");
  const election = await Election.deploy();


  await election.getDeployedCode ? await election.waitForDeployment() : await election.deployed();


  const contractAddress = election.target || election.address;
  
  console.log("ScientificClubElection deployed to:", contractAddress);

  const contractsDir = path.resolve(__dirname, "..", "client", "src", "contracts-data");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir, { recursive: true });
  }

  const abi = JSON.parse(election.interface.formatJson ? election.interface.formatJson() : election.interface.format('json'));

  fs.writeFileSync(
    path.join(contractsDir, "ScientificClubElection.json"),
    JSON.stringify({
      address: contractAddress,
      abi: abi
    }, null, 2)
  );

  console.log("Contract data successfully saved to client/src/contracts-data/");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });