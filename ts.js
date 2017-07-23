var Mobinsure = artifacts.require("./Mobinsure.sol")
var mobinsure = Mobinsure.at(Mobinsure.address)
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
var utils = require("./utils.js")

var policyValue = web3.toWei(0.1, 'ether');

// Copied from some StackOverflow post.
function httpGetAsync(theUrl, callback) {
	var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() { 
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
            callback(xmlHttp.responseText);
    }
    xmlHttp.open("GET", theUrl, true); // true for asynchronous 
    xmlHttp.send(null);
}

var watchForPolicyCreation = imeiString => {
	var buyPolicySuccessfullyMade = mobinsure.LogBuyPolicySuccess({ imei: imeiString })
 	buyPolicySuccessfullyMade.watch((error, response) => {
 		if (!error) {
			console.log("Policy Purchased Imei: " + response.args.imei + " Policy owner: " + response.args.policyOwner + " Time invalid: " + response.args.timePolicyInvalid)
			buyPolicySuccessfullyMade.stopWatching()
		} else {
			console.log(error)
		}
	})
}

var watchForClaimMade = imeiString => {
	var claimSuccessfullyMade = mobinsure.LogMakeClaimSuccess({ imei: imeiString })
	claimSuccessfullyMade.watch((error, response) => {
		console.log("Policy owner: " + response.args.imei + " Payout (eth): " + web3.fromWei(response.args.payout, 'ether'))
		claimSuccessfullyMade.stopWatching()
	}) 
}

var buyPolicy = (fromAccount, imei, blockedStatus) => 
	mobinsure.buyPolicy(imei, blockedStatus, { from: web3.eth.accounts[fromAccount], value: policyValue })
	.then(tx => {
		watchForPolicyCreation(imei)
		console.log("Buy policy tx made from account " + fromAccount + " with IMEI: " + imei) 
	})

var makeClaim = (fromAccount, imei, blockedStatus) => 
	mobinsure.makeClaim(imei, blockedStatus, { from: web3.eth.accounts[fromAccount] })
	.then(tx => { 
		watchForClaimMade(imei)
		console.log("Claim tx made from account " + fromAccount + " for IMEI: " + imei)
	})

var getOraclizeFee = () => mobinsure.getOraclizeFee()
	.then(fee => console.log("Oraclize fee: " + fee))

mobinsure.PRICE_CHECK_URL().then(cryptoCompare => 
	mobinsure.PREMIUM_VALUE_GBP()
		.then(premium => httpGetAsync("https://min-api.cryptocompare.com/data/price?fsym=GBP&tsyms=ETH", 
			response => console.log("£" + premium + " in Eth: " + ((JSON.parse(response).ETH) * premium)))))


// Note, it appears I do not understand indexed events properly so all the following tx's logs are called at once.
// Keeps crashing when I use indexed logs.
// utils.balances(2)
// buyPolicy(0, "1", "unblocked")
// 	.then(() => buyPolicy(1, "2", "unblocked"))
// 	.then(() => buyPolicy(0, "3", "unblocked"))
// 	.then(() => buyPolicy(1, "4", "unblocked"))
// 	.then(() => buyPolicy(0, "5", "unblocked"))
// 	.then(() => buyPolicy(1, "6", "unblocked"))
// 	.then(() => buyPolicy(0, "7", "unblocked"))
// 	.then(() => utils.balances(2))

makeClaim(1, "2", "blocked")
	.then(() => utils.balances(2))


module.exports = callback => {}