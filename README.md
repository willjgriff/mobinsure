<b>Mobinsure</b>
<br>Peer to Peer Mobile Insurance where claims paid out are dependant on whether the IMEI of a phone is blocked. Current implementation is for a single premium and payout value. It is assumed that if an IMEI is blocked, determined by the IMEI oracle, the phone is unusable and therefore the policy holder deserves a payout. Many assumptions and improvements are littered as comments around Mobinsure.sol and should be referred to here as well.

<b>Tech used</b><br> <b>CryptoCompare API</b> - to fetch conversion data from GBP to ETH (would be extended to other currencies in future). 
<b>Oraclize</b> - to communicate with CryptoCompare. It also fakes Oraclize usage for fetching the IMEI data.

<b>Basic Walkthrough</b>
<br>The contract has two public functions for its main usage. ```buyPolicy()``` which requires a mobiles IMEI. It also accepts the current blocked status of the IMEI for demonstration purposes only, this would be got from the IMEI oracle in reality. Before registering, it does a price check using oraclize to check the payment sent is equal to GBP premium value in ether. If the payment is correct it then does an Oraclize request to fetch the IMEI data and checks the IMEI is not already blocked, if it isn't it then it registers the policy to that IMEI and the senders address.

Once an IMEI is blocked, and the IMEI oracle will report this, the user can claim using ```makeClaim()``` which accepts the IMEI to determine the policy. It also accepts the current blocked status of the IMEI for demonstration purposes only, this would be got from the IMEI oracle in reality. Before making a payout it checks the IMEI policy is within its insured period then creates an Oraclize request to fetch the IMEI data to check it is now blocked, it then makes a payout to the account that made the policy and invalidates the policy for further claims. 

<b>Example usage</b>
Requires ```npm install``` to install web3 package to local dir. Then from a truffle console ```migrate``` to deploy the Mobinsure.sol contract.
ts.js is a test script for interacting with the Truffle deployed contract. It includes a bunch of JS functions calling functions from the Mobinsure.sol contract and some commented example execution. 
To test, uncomment buyPolicy() function calls and comment makeClaim() call. Execute in truffle console with ```exec ts.js```. Wait for the log statement that verifies the price check has been completed. Then comment buyPolicy() function calls and uncomment makeClaim() call, execute ts.js again to test claiming.



<b>Necessary extensions:</b> There are no free providers of the IMEI data that this system requires. In the full system we would require an incentivised policy value weighted voting mechanism for determining the IMEI data provider and a mechanism for allowing the IMEI data provider to take payment (payment also determined by vote). To bootstrap we would find an initial IMEI provider not voted in by policy holders.

Currently only one policy is available. We should have multiple policies, one for each device. When buying policies, we should check the IMEI number to find the device and it's age and use this to determine and the premium / payout for the policy. The premium's and payout's should also be recalculated when policies are bought (for the next policy purchase) dependant on the balance in the contract and previous number of claims.

<b>Potential extensions:</br> Integrate a governance / voting system which can dynamically add claiming methods. A bit farfetched perhaps, would require a lot of thought but probably possible.

For commit history see previous repo: https://github.com/willjgriff/hackathon-break-the-block/commits/master
