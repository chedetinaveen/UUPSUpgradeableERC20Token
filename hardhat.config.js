require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");


module.exports = {
  solidity: "0.8.2",
  networks: {
    ropsten: {
      url: 'https://ropsten.infura.io/v3/62febf6a973c4e9389ccd0cb4f58c48d',
      accounts: ['818d5c4f9fa0b836a6bb9fe55c707588466d1549da255c3f71b2e7637b37ab42'],
    }
  },
  etherscan: {
    apiKey: {
      ropsten: 'QIC6CQ7ZF5E4EF9PC74RE9H18BAZPWBKTM',
    }
  }
};
