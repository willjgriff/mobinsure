pragma solidity ^0.4.11;

import { usingOraclize } from "./Oraclize.sol";
import { OraclizeAddrResolverI } from "./Oraclize.sol";

// Assumes a single policy for a single type of device for now. 
// Imei data provider should be voted in with an incentivised policy value weighted vote during a pre-determined period.
contract Mobinsure is usingOraclize {

	// These constants should be editable as the sources of data are likely to change. Changes should be 
	// administered by a trusted multi-sig enabled party or a voting system.
    string public constant BLOCKED_IMEI = "blocked";
    string private constant ORACLIZE_DATA_SOURCE = "URL";
    string public constant PRICE_CHECK_URL = "https://min-api.cryptocompare.com/data/price?fsym=GBP&tsyms=ETH";
    // Could be dyanmic determined by the balance in the pool and number of claims made and or voting by policy holders.
    // Also dependant on geography.
    uint public constant PREMIUM_VALUE_GBP = 5;
    // This should by dynamic dependant on the age of the device and a price check against a local currecny
    // (phone age can be determined by the Imei number)
    uint public constant PAYOUT_VALUE = 0.08 ether; // roughly £15 which requires 3 policies before payout can be made.
    
    // See if we can reduce data usage here. Split up PolicyHolder perhaps
    mapping(string => PolicyHolder) private imeiPolicies;
    mapping(bytes32 => PolicyHolder) private oraclizePriceCheckQueries;
    mapping(bytes32 => bytes32) private oraclizePolicyQueries;
    mapping(bytes32 => string) private oraclizeClaimQueries;
    
    struct PolicyHolder {
        string imei;
        address policyOwner;
        uint timePolicyInvalid;
        uint valuePayed;
        // Just for demonstration purposes, to be removed in favour of Oraclize response
        string blockedStatus;
    }

    event LogBuyPolicySuccess(string imei, address policyOwner, uint timePolicyInvalid);

    event LogMakeClaimSuccess(string imei, uint payout);

    function Mobinsure() {
    	// TODO: Delete this, for testing with private chain (testrpc) only
		OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    }
    
    // Includes margin of error. The upper / lower limits aren't correct. 
    // Not sure how to convert fractional Eth value into whole Wei value.
    modifier correctPayment(bytes32 priceCheckQueryId, string value) { 
    	uint valuePayed = oraclizePriceCheckQueries[priceCheckQueryId].valuePayed;
    	uint premiumInEth = parseInt(value) * PREMIUM_VALUE_GBP;
    	uint upperLimit = (premiumInEth) + 10000000000000000000;
    	uint lowerLimit = 0;
    	require(valuePayed >= lowerLimit && valuePayed <= upperLimit);
    	_;
    }
    
    modifier imeiIsInsured(string imei) { require(imeiPolicies[imei].timePolicyInvalid > now); _; }
    
    modifier imeiIsUnblocked(string oraclizeResponse) { require(isImeiBlocked(oraclizeResponse) == false); _; }
    
    modifier imeiIsBlocked(string oraclizeResponse) { require(isImeiBlocked(oraclizeResponse)); _; }
    
    // The string that represents a blocked Imei (in this case BLOCKED_IMEI) will be determined by the
    // Imei data provider, this should be dynamic if the Imei data provider can be voted in. 
    function isImeiBlocked(string oraclizeResponse) private returns(bool) {
        return sha3(oraclizeResponse) == sha3(BLOCKED_IMEI);
    }

	// imeiBlockedStatus arg is for demonstration purposes only, this value would be determined by Oraclize in reality.
	// Potential vulnerability, this currently allowes someone to insure an Imei from a different address even after it is already insured.
    function buyPolicy(string _imei, string imeiBlockedStatus) public payable {
    	// bytes32 priceCheckQueryId = oraclize_query(ORACLIZE_DATA_SOURCE, strConcat("json(", PRICE_CHECK_URL, ").ETH"));
    	bytes32 priceCheckQueryId = oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=GBP&tsyms=ETH).ETH");
    	oraclizePriceCheckQueries[priceCheckQueryId].imei = _imei;
        oraclizePriceCheckQueries[priceCheckQueryId].policyOwner = msg.sender;
        oraclizePriceCheckQueries[priceCheckQueryId].valuePayed = msg.value;
        oraclizePriceCheckQueries[priceCheckQueryId].blockedStatus = imeiBlockedStatus;
    }
	
	// imeiBlockedStatus arg is for demonstration purposes only, this value would be determined by Oraclize in reality.
	function makeClaim(string imei, string imeiBlockedStatus) public imeiIsInsured(imei) 
	{
	    // Make oraclize call to check Imei is now blocked. Oraclize fee is paid by premiums.
	    // bytes32 queryId = oraclize_query(Call imei provider with policyHolders[msg.sender].imei)
		bytes32 queryId = 123;
		oraclizeClaimQueries[queryId] = imei;
	    __callback(queryId, imeiBlockedStatus);
	}
	
	function __callback(bytes32 oraclizeId, string response) public {
		if (sha3(oraclizePriceCheckQueries[oraclizeId].imei) != sha3("")) {
			confirmPriceCheck(oraclizeId, response);
		} else if (oraclizePolicyQueries[oraclizeId] != 0) {
	        confirmBuyPolicy(oraclizeId, response);
	    } else if (sha3(oraclizeClaimQueries[oraclizeId]) != sha3("")) {
	        confirmMakeClaim(oraclizeId, response);
	    }
	}

	function confirmPriceCheck(bytes32 priceCheckQueryId, string response) private correctPayment(priceCheckQueryId, response) {
	    // We check the Imei is not on a black list using Oraclize. Oraclize fee is paid by the premium.
	    // We could also get the phone type when extending the policy to multiple device types.
	    // bytes32 queryId = oraclize_query(Call imei provider with imei)
	    bytes32 imeiQueryId = 321;
        oraclizePolicyQueries[imeiQueryId] = priceCheckQueryId;
		__callback(imeiQueryId, oraclizePriceCheckQueries[priceCheckQueryId].blockedStatus);
	}
	
	function confirmBuyPolicy(bytes32 oraclizeId, string response) private imeiIsUnblocked(response) {
	    bytes32 PriceCheckQueryId = oraclizePolicyQueries[oraclizeId];
	    // Should probably return the premium if Imei is blocked or Oraclize fails, or we could keep it as a penalty.
	    PolicyHolder policyHolder = oraclizePriceCheckQueries[PriceCheckQueryId];
	    string imei = policyHolder.imei;
	    imeiPolicies[imei].imei = imei;
	    imeiPolicies[imei].policyOwner = policyHolder.policyOwner;
	    imeiPolicies[imei].timePolicyInvalid = now + 4 weeks;
	    LogBuyPolicySuccess(imeiPolicies[imei].imei, imeiPolicies[imei].policyOwner, imeiPolicies[imei].timePolicyInvalid);
	}
	
	function confirmMakeClaim(bytes32 oraclizeId, string response) private imeiIsBlocked(response) {
	    string storage imeiClaim = oraclizeClaimQueries[oraclizeId];
	    imeiPolicies[imeiClaim].timePolicyInvalid = 0;
	    imeiPolicies[imeiClaim].policyOwner.transfer(PAYOUT_VALUE);
	    LogMakeClaimSuccess(imeiClaim, PAYOUT_VALUE);
	    oraclizeClaimQueries[oraclizeId] = "";
	}
	
	function getOraclizeFee() public constant returns(uint) {
		return oraclize_getPrice(ORACLIZE_DATA_SOURCE);
	}

	function () {
		revert();
	}
}











