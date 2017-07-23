<b>Mobinsure</b>
<br>Peer to Peer Mobile Insurance where claims paid out are dependant on whether the IMEI of a phone is blocked. Uses the CryptoCompare API to fetch conversion data from GBP to ETH for premium rate (would be extended to determine payout rate and to other currencies in future). Uses Oraclize to fetch the data and fakes Oraclize usage for fetching the IMEI data. Many assumptions and improvements are littered as comments around Mobinsure.sol.

Built with Truffle, note it includes Oraclize ethereum-bridge interface declaration in Mobinsure.sol for use with testrpc. This should be removed when testing on a testnet or mainnet.

Requires ```npm install``` to install web3 package to local dir.
To test ts.js is a test script for interacting with the Truffle deployed contract. Including a bunch of JS functions representing functions from the Mobinsure.sol contract and some commented example execution. To test, uncomment buyPolicy() function calls and comment makeClaim() calls. Execute in truffle console with ```exec ts.js```. Then switch the commented functions and execute again to test claiming.

For commit history see previous repo: https://github.com/willjgriff/hackathon-break-the-block/commits/master
