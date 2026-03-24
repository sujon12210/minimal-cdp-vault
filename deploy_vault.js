const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  // Deploy Mock Collateral (e.g., WBTC)
  const MockERC20 = await hre.ethers.getContractFactory("StableCoin"); // Reusing for simplicity
  const collateral = await MockERC20.deploy();
  await collateral.waitForDeployment();

  // Deploy Debt Token (mUSD)
  const DebtToken = await hre.ethers.getContractFactory("StableCoin");
  const debt = await DebtToken.deploy();
  await debt.waitForDeployment();

  // Deploy Vault
  const Vault = await hre.ethers.getContractFactory("CDPVault");
  const vault = await Vault.deploy(await collateral.getAddress(), await debt.getAddress());
  await vault.waitForDeployment();

  // Transfer ownership of Debt token to Vault so it can mint/burn
  await debt.transferOwnership(await vault.getAddress());

  console.log("CDP System Deployed:");
  console.log("- Collateral:", await collateral.getAddress());
  console.log("- Debt Token:", await debt.getAddress());
  console.log("- Vault:", await vault.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
