pragma solidity ^0.4.4;

import "./math/SafeMath.sol";
import "./token/StandardToken.sol";
import "./ownership/Ownable.sol";
import "./lib/DateTime.sol";

contract CREDToken is StandardToken, Ownable
{
    using SafeMath for uint256;

    struct UniqueAddressSet
    {
	mapping (address => uint16) addxIndex;
	mapping (uint16 => address) addxs;
	uint16 size;
    }

    UniqueAddressSet public whitelistAddresses;
    UniqueAddressSet public advisorsAddresses;
    UniqueAddressSet public teamAddresses;

    struct KYCAddressSet
    {
	mapping (address => uint256) addxIndex;
	mapping (uint256 => address) addxs;
	uint256 size;
	mapping (uint256 => bool) isVerified;
	mapping (uint256 => uint256) weiSpent;
	mapping (uint256 => uint256) tokensPurchased;
	mapping (uint256 => uint256) lastPurchaseTimestamp;
    }

    KYCAddressSet customerInfo;

    function isInCustomerList(address addx) internal returns (bool)
    {
	if (addx == customerInfo.addxs[0]) return true;
	else return (customerInfo.addxIndex[addx] != 0);
    }
    
    function _AddNewCustomer(address addx, uint256 weiSpent, uint256 tokensPurchased) internal
    {
            customerInfo.addxs[customerInfo.size] = addx;
            customerInfo.weiSpent[customerInfo.size] = weiSpent;
            customerInfo.tokensPurchased[customerInfo.size] = tokensPurchased;
            customerInfo.lastPurchaseTimestamp[customerInfo.size] = now;
            customerInfo.addxIndex[addx] = customerInfo.size;
            ++customerInfo.size;
    }

    function _UpdateCustomer(address addx, uint256 weiSpent, uint256 tokensPurchased) internal
    {
	uint256 cIndex = customerInfo.addxIndex[addx];
	customerInfo.weiSpent[cIndex] += weiSpent;
        customerInfo.tokensPurchased[cIndex] += tokensPurchased;
        customerInfo.lastPurchaseTimestamp[cIndex] = now;
        
    }

    uint256 rate;
    uint256 cap;
    address verifyWallet;
    address verifyFundWallet;
    uint256 public earlyInvestorsBalance;
    uint256 public futureTokenSaleBalance;
    uint256 public tokenSaleBalance;
    uint256 public verifyTeamBalance;
    uint256 public advisorsBalance;
    uint256 public bountyBalance;
    uint256 public weiRaised;
    DateTime public dtUtils;
    
    uint256 public earlyTokensaleStartTime;
    uint256 public tokensaleStartTime;
    uint256 public futureTokensaleTime;
    uint256 public verifyTeamLockTime;
    uint256 public advisorsLockTime1;
    uint256 public advisorsLockTime2;
    
    bool contractDeployed;
    bool capReached;
    
    function releaseLocked() onlyOwner public
    {
	if (now > earlyTokensaleStartTime) balances[verifyWallet] = balances[verifyWallet] + earlyInvestorsBalance;
	if (now > futureTokensaleTime) balances[verifyWallet] = balances[verifyWallet] + futureTokenSaleBalance;
	if (now > verifyTeamLockTime) balances[verifyWallet] = balances[verifyWallet] + verifyTeamLockTime;
	if (now > advisorsLockTime2) balances[verifyWallet] = balances[verifyWallet] + advisorsBalance;
    }

    function setEarlyTokenSaleTime(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public onlyOwner
    {
	if (!contractDeployed)
	{
	    earlyTokensaleStartTime = dtUtils.toTimestamp(year, month, day, hour, minute);
	}
    }
    
    function setTokensaleTime(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public onlyOwner
    {
	if (!contractDeployed)
	{
	    tokensaleStartTime = dtUtils.toTimestamp(year, month, day, hour, minute);
	}
    }

    function setFutureTokensaleTime(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public onlyOwner
    {
	if (!contractDeployed)
	{
	    futureTokensaleTime = dtUtils.toTimestamp(year, month, day, hour, minute);
	}
    }

    
    function setVerifyTeamLockTime(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public onlyOwner
    {
	if (!contractDeployed)
	{
	    verifyTeamLockTime = dtUtils.toTimestamp(year, month, day, hour, minute);
	}
    }
    
    function setAdvisorsLockTime1(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public onlyOwner
    {
	if (!contractDeployed)
	{
	    advisorsLockTime1 = dtUtils.toTimestamp(year, month, day, hour, minute);
	}
    }
    
    function setAdvisorsLockTime2(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public onlyOwner
    {
	if (!contractDeployed)
	{
	    advisorsLockTime2 = dtUtils.toTimestamp(year, month, day, hour, minute);
	}
    }

    function setVerifyWallet(address vwAddress) onlyOwner public
    {
	if (!contractDeployed)
	{
	    verifyWallet = vwAddress;
	}    
    }
    
    function deployContract() public onlyOwner
    {
	contractDeployed = true;
    }

    function CREDToken()
    {
	rate = 1333;
	contractDeployed = false;
	weiRaised = 0;
	verifyWallet = 0xB4e817449b2fcDEc82e69f02454B42FE95D4d1fD;
	verifyWallet = 0x230F6960032714894bb060C837d099cff71D5285; //privatenetWallet
	verifyFundWallet = 0x028e27D09bb37FA00a1691fFE935D190C8D1668c;
	verifyFundWallet = 0xC2651a4c61e55bFb8097A191eeeeD1C0c8F13b9a; //privatenetWallet

	totalSupply =                50000000000000000000000000;
	cap =                            1666000000000000000000;
	
	balances[verifyFundWallet] = 10500000000000000000000000;
//	balances[verifyWallet] =     39500000000000000000000000;
	balances[verifyWallet] =     11125000000000000000000000;

	earlyInvestorsBalance =       2000000000000000000000000;
	tokenSaleBalance =           11125000000000000000000000;
	futureTokenSaleBalance =     10000000000000000000000000;
	verifyTeamBalance =          10000000000000000000000000;
	advisorsBalance =             5500000000000000000000000;
	bountyBalance =                875000000000000000000000;
	dtUtils = new DateTime();
    }

    function InitializeToken() public onlyOwner
    {
    
    }
    
    function () payable {
	buyCREDTokens(msg.sender);
    }

    

    function releaseFutureSale() onlyOwner public
    {
	if (now > futureTokensaleTime) balances[verifyWallet] = balances[verifyWallet] + futureTokenSaleBalance;
	if (now > futureTokensaleTime) balances[verifyWallet] = balances[verifyWallet] + futureTokenSaleBalance;
	if (now > futureTokensaleTime) balances[verifyWallet] = balances[verifyWallet] + futureTokenSaleBalance;
	if (now > futureTokensaleTime) balances[verifyWallet] = balances[verifyWallet] + futureTokenSaleBalance;
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
//	bool withinPeriod = now >= startTime && now <= endTime;
	bool nonZeroPurchase = msg.value != 0;
//	return withinPeriod && nonZeroPurchase;
	return nonZeroPurchase;
    }
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event EarlyInvestorsBalanceReleased(address own, string message, uint256 TokensAdded);
    event TokenSaleIsNotAllowed(address sender, string message, uint256 amount);
    event OutOfTokens(address sender, string message, uint256 lastPurchase);
    
    function buyCREDTokens(address beneficiary) public payable {
	require(beneficiary != 0x0);
//	require(validPurchase());
	uint256 tokenDiff = 0;
        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

	if (now > tokensaleStartTime)
	{
	    if (earlyInvestorsBalance > 0)
	    {
		balances[verifyWallet] = balances[verifyWallet] + earlyInvestorsBalance;
		EarlyInvestorsBalanceReleased(msg.sender, "Tokens Transferred to verifyWallet",  earlyInvestorsBalance);
		earlyInvestorsBalance = 0;

	    }

	    if (tokens > balances[verifyWallet])
	    {
		OutOfTokens(msg.sender, "VerifyWallet out of tokens", tokens);
		tokenDiff = tokens - balances[verifyWallet];
		tokens = balances[verifyWallet];
	    }
	    
	    sellTokens(tokens);
	    tokenSaleBalance.sub(tokens);
	    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

	    forwardOrRefund(tokenDiff);

	}
	else 
	    if ((now > earlyTokensaleStartTime) && isInWhiteList(msg.sender))
	    {
		if (tokens > earlyInvestorsBalance)
		{
		    OutOfTokens(msg.sender, "Early Investors Fund out of tokens", tokens);
		    tokenDiff = tokens - earlyInvestorsBalance;
		    tokens = earlyInvestorsBalance;
		}

		balances[msg.sender] = balances[msg.sender] + tokens;
		earlyInvestorsBalance -= tokens;
		TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

		forwardOrRefund(tokenDiff);
		
	    }
	    else
	    {
		TokenSaleIsNotAllowed(msg.sender, "Refunded", msg.value);
		refundBack(msg.value);
	    }

    }

    function forwardOrRefund(uint256 tokenDiff) internal
    {
    	    uint256 weiRefund = 0;
	    if (tokenDiff > 0)
	    {
		weiRefund = tokenDiff.div(rate);
		refundBack(weiRefund);
	    }
	    forwardFunds(msg.value - weiRefund);
	    // update state
            weiRaised = weiRaised.add(msg.value - weiRefund);
    }
    
    function isInWhiteList(address addx) internal returns (bool)
    {
	if (addx == whitelistAddresses.addxs[0]) return true;
	else return (whitelistAddresses.addxIndex[addx] != 0);
    }

    function isInTeamList(address addx) internal returns (bool)
    {
	if (addx == teamAddresses.addxs[0]) return true;
	else return (teamAddresses.addxIndex[addx] != 0);
    }

    function isInAdvisorsList(address addx) internal returns (bool)
    {
	if (addx == advisorsAddresses.addxs[0]) return true;
	else return (advisorsAddresses.addxIndex[addx] != 0);
    }


    function forwardFunds(uint256 val) internal {
	verifyWallet.transfer(val);
    }

    event WeiRefunded(address sender, string message, uint256 amount);
    function refundBack(uint256 weis) internal {
	msg.sender.transfer(weis);
	WeiRefunded(msg.sender, "Refunded: ", weis);
    }

    function sellTokens(uint256 tokens) internal
    {
	balances[verifyWallet] = balances[verifyWallet] - tokens;
	balances[msg.sender] = balances[msg.sender] + tokens;
    }

    event BountyTokensTransferred(address sender, address recipient, uint256 amount);
    event NotEnoughBountyTokens(address sender, uint256 avaliableBalance, uint256 attemptedTransfer);
    function bountyTransfer(address addx, uint256 amount) onlyOwner public returns (bool)
    {
	if (amount <= bountyBalance)
	{
	    balances[addx] = balances[addx] + amount;
	    bountyBalance -= amount;
	    BountyTokensTransferred(msg.sender, addx, amount);
	    return true;
	}
	else
	{
	    NotEnoughBountyTokens(msg.sender, bountyBalance, amount);
	    return false;
	}
    }

    event TeamTokensTransferred(address sender, address recipient, uint256 amount);
    event NotEnoughTeamTokens(address sender, uint256 avaliableBalance, uint256 attemptedTransfer);
    function teamTransfer(address addx, uint256 amount) onlyOwner public returns (bool)
    {
	if (isInTeamList(addx))
	{
	    if (amount <= verifyTeamBalance)
	    {
		balances[addx] = balances[addx] + amount;
    		verifyTeamBalance -= amount;
		TeamTokensTransferred(msg.sender, addx, amount);
		return true;
	    }
	    else
	    {
		NotEnoughTeamTokens(msg.sender, bountyBalance, amount);
		return false;
	    }
	}
	else return false;
    }

    event AdvisorsTokensTransferred(address sender, address recipient, uint256 amount);
    event NotEnoughAdvisorsTokens(address sender, uint256 avaliableBalance, uint256 attemptedTransfer);
    event AdvisorsTokensLocked(address sender, string message, uint256 timestamp);
    function advisorsTransfer(address addx, uint256 amount) onlyOwner public returns (bool)
    {
	if (now < advisorsLockTime1)
	    AdvisorsTokensLocked(msg.sender, "Tokens locked till", advisorsLockTime1);
	if (isInAdvisorsList(addx))
	{
	    if (amount <= advisorsBalance)
	    {
		balances[addx] = balances[addx] + amount;
    		advisorsBalance -= amount;
		AdvisorsTokensTransferred(msg.sender, addx, amount);
		return true;
	    }
	    else
	    {
		NotEnoughAdvisorsTokens(msg.sender, bountyBalance, amount);
		return false;
	    }
	}
	else return false;
    }


    event AddressAddedToWhiteList(address sender, uint16 index, address addx);
    function _AddAddressToWL(address addx) internal
    {
            whitelistAddresses.addxs[whitelistAddresses.size] = addx;
            whitelistAddresses.addxIndex[addx] = whitelistAddresses.size;
            AddressAddedToWhiteList(msg.sender, whitelistAddresses.size, addx);
            ++whitelistAddresses.size;
	    _AddNewCustomer(addx, 0, 0);
	    setAddressVerified(addx);
    }

    function _AddAddressToAL(address addx) internal
    {
            advisorsAddresses.addxs[advisorsAddresses.size] = addx;
            advisorsAddresses.addxIndex[addx] = advisorsAddresses.size;
            ++advisorsAddresses.size;
	    _AddNewCustomer(addx, 0, 0);
	    setAddressVerified(addx);

    }

    function _AddAddressToTL(address addx) internal
    {
            teamAddresses.addxs[teamAddresses.size] = addx;
            teamAddresses.addxIndex[addx] = teamAddresses.size;
            ++teamAddresses.size;
	    _AddNewCustomer(addx, 0, 0);
	    setAddressVerified(addx);
    }

    function setAddressVerified(address addx) onlyOwner public returns(bool)
    {
	uint256 cIndex = customerInfo.addxIndex[addx];
	customerInfo.isVerified[cIndex] = true;
    }
    
    event AddTolist(address addx, string listname, uint16 index);
    event AddressAlreadyInList(address sender, string message, string listname);
    function AddAdressesToWhitelist(address[] addxs) onlyOwner
    {
	for (uint16 i = 0; i < addxs.length; ++i)
	{
	    AddTolist(addxs[i], "Whitelist", i);
	    if (whitelistAddresses.size == 0)
	    {
		_AddAddressToWL(addxs[i]);
	    }
    	    else {
    		if (whitelistAddresses.addxIndex[addxs[i]] == 0 && whitelistAddresses.addxs[0] != addxs[i])
    		{
		    _AddAddressToWL(addxs[i]);
    		}
    		else AddressAlreadyInList(msg.sender, "Address already in ", "Whitelist");
    	    }

	}
    }

    function AddAdressesToAdvisorslist(address[] addxs) onlyOwner
    {
	for (uint16 i = 0; i < addxs.length; ++i)
	{
	    AddTolist(addxs[i], "Advisors", i);
	    if (advisorsAddresses.size == 0)
	    {
		_AddAddressToAL(addxs[i]);
	    }
    	    else {
    		if (advisorsAddresses.addxIndex[addxs[i]] == 0 && advisorsAddresses.addxs[0] != addxs[i])
    		{
		    _AddAddressToAL(addxs[i]);
    		}
    		else AddressAlreadyInList(msg.sender, "Address already in ", "Advisors list");
    	    }

	}
    }

    function AddAdressesToTeamlist(address[] addxs) onlyOwner
    {
	for (uint16 i = 0; i < addxs.length; ++i)
	{
	    AddTolist(addxs[i], "Team", i);
	    if (teamAddresses.size == 0)
	    {
		_AddAddressToTL(addxs[i]);
	    }
    	    else {
    		if (teamAddresses.addxIndex[addxs[i]] == 0 && teamAddresses.addxs[0] != addxs[i])
    		{
		    _AddAddressToTL(addxs[i]);
    		}
    		else AddressAlreadyInList(msg.sender, "Address already in ", "Team list");
    	    }

	}
    }

    event ListWhitelist(address sender, uint16 index, address addx);
    function ListWhitelistAddresses() onlyOwner public
    {
	for (uint16 i = 0; i < whitelistAddresses.size; ++i)
	{
	    ListWhitelist(msg.sender, i, whitelistAddresses.addxs[i]);
	}
    }

    event ListAdvisors(address sender, uint16 index, address addx);
    function ListAdvisorsAddresses() onlyOwner
    {
	for (uint16 i = 0; i < advisorsAddresses.size; ++i)
	{
	    ListWhitelist(msg.sender, i, advisorsAddresses.addxs[i]);
	}
    }

    event ListTeam(address sender, uint16 index, address addx);
    function ListTeamAddresses() public onlyOwner
    {
	for (uint16 i = 0; i < teamAddresses.size; ++i)
	{
	    ListWhitelist(msg.sender, i, teamAddresses.addxs[i]);
	}
    }

}
