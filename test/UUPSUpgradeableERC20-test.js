const { expect } = require("chai");
const { ethers } = require("hardhat");

let token;
let accounts;
let owner;

beforeEach(async function () {
  accounts = await ethers.getSigners();
  const Token = await ethers.getContractFactory("UUPSUpgradeableERC20Token");
  token = await upgrades.deployProxy(Token, ["Token", "TKN", 1000000, 100000], {
      initializer: "initialize",
  });
  await token.deployed();
  owner = accounts[0];
});

describe("Token", function () {
  it("Owner", async function() {
    expect(await token.owner()).to.equal(owner.address);
  })

  it("Test Cap", async function () {
    expect(await token.cap()).to.equal("1000000000000000000000000");
  });

  it("Mint tokens", async function () {
    await token.mint(owner.address, 100000);
    totalSupply = await token.totalSupply();
    expect(totalSupply).to.equal("100000000000000000100000");
  });

  it("Owner supply = total supply", async function () {
    const ownerBalance = await token.balanceOf(owner.address);
    expect(await token.totalSupply()).to.equal(ownerBalance);
  })

  it("Burn tokens", async function () {
    totalSupply = await token.totalSupply();
    await token.mint(owner.address, 10);
    await token.burn(owner.address, 10);
    expect(await token.totalSupply()).to.equal(totalSupply);
  })

  it("Transfer tokens without burn", async function () {
    account2 = accounts[1];
    await token.transfer(account2.address, 100);
    expect(await token.balanceOf(account2.address)).to.equal(100);
  })

  it("Transfer tokens with burn", async function () {
    account2 = accounts[1];
    await token.mint(owner.address, 1000);
    await token.transfer(account2.address, 100);
    expect(await token.balanceOf(account2.address)).to.equal(90);
  })

});
