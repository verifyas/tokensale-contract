module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
//      from: "0x2614fc992d789b739254a8b52f52e8605de3444e",
      from: "0x7a56d49393c728b9607666e07fff5e55f51d89f6",
      gas: 4712387,
    }
  },
  optimizer:
  {
    "enabled": false,
//    "runs": 200
  }
};
