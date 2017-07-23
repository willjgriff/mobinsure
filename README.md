<b>Mobinsure</b>
<br>Peer to Peer Mobile Insurance where claims paid out are dependant on whether the IMEI of a phone is blocked. Current implementation is for a single premium and payout value. It is assumed that if an IMEI is blocked, determined by the IMEI oracle, the phone is unusable and therefore the policy holder deserves a payout. Many assumptions and improvements are littered as comments around Mobinsure.sol.



<b>Tech used:</b> CryptoCompare API to fetch conversion data from GBP to ETH (would be extended to other currencies in future). Oraclize to fetch the price data. It also fakes Oraclize usage for fetching the IMEI data.

<b>Standard usage:</b> Requires ```npm install``` to install web3 package to local dir.
To test ts.js is a test script for interacting with the Truffle deployed contract. Including a bunch of JS functions representing functions from the Mobinsure.sol contract and some commented example execution. To test, uncomment buyPolicy() function calls and comment makeClaim() calls. Execute in truffle console with ```exec ts.js```. Then switch the commented functions and execute again to test claiming.



<b>Necessary extensions:</b> There are no free providers of the IMEI data that this system requires. In the full system we would require an incentivised policy value weighted voting mechanism for determining the IMEI data provider and a mechanism for allowing the IMEI data provider to take payment (payment also determined by vote). To bootstrap we would find an initial IMEI provider not voted in by policy holders.

Currently only one policy is available. We should have multiple policies, one for each device. When buying policies, we should check the IMEI number to find the device and it's age and use this to determine and the premium / payout for the policy. The premium's and payout's should also be recalculated when policies are bought (for the next policy purchase) dependant on the balance in the contract and previous number of claims.

<b>Potential extensions:</br> Integrate a governance / voting system which can dynamically add claiming methods. A bit farfetched perhaps, would require a lot of thought but probably possible.

For commit history see previous repo: https://github.com/willjgriff/hackathon-break-the-block/commits/master
