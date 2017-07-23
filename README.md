<b>Mobinsure</b> - Peer to Peer Mobile Insurance where claims paid out are dependant on whether the IMEI of a phone is blocked. Uses the CryptoCompare API to fetch conversion data from GBP to ETH (would be extended to other currencies in future). Uses Oraclize to fetch the data and fakes Oraclize usage for fetching the IMEI data.

<br>Built with Truffle, note it includes Oraclize ethereum-bridge interface declaration for use with testrpc. This should be removed when testing on a testnet or mainnet.

<br>Requires 'npm install' to install web3 package to local dir.
<br>To test ts.js is a test script for interacting with the Truffle deployed contract. Including a bunch of JS functions representing functions from the Mobinsure.sol contract and some commented example execution. To test, uncomment buyPolicy() function calls and comment makeClaim() calls. Execute in truffle console with 'exec ts.js'. Then switch the commented functions and execute again to test claiming.