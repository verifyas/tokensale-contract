module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      from: "0x1ecca967aad513e59384eac3ddf451266698cb9b",
      gas: 4712388,
    }
  },
  optimizer:
  {
    "enabled": false,
//    "runs": 200
  }
};
