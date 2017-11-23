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

    mapping (address => bool) public isAddressVerified;

    uint256 rate;
    uint256 cap;
    address verifyWallet;
    address verifyFundWallet;
    uint256 public earlyInvestorsBalance;
    uint256 public futureTokenSaleBalance;
    uint256 public tokenSaleBalance;
    uint256 public verifyTeamBalance;
    uint256 public verifyTeamVested;
    uint256 public advisorsBalance;
    uint256 public bountyBalance;
    uint256 public weiRaised;
    uint256 public advisorsVested;
    DateTime public dtUtils;
    
    uint256 public earlyTokensaleStartTime;
    uint256 public tokensaleStartTime;
    uint256 public verifyTeamLockTime;
    uint256 public advisorsLockTime1;
    uint256 public advisorsLockTime2;
    
    bool contractDeployed;
    bool capReached;
    
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
	verifyWallet = 0x7a56d49393c728B9607666e07fFf5E55F51d89f6; //privatenetWallet
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
	verifyTeamVested =                                    0;
	advisorsBalance =             5500000000000000000000000;
	advisorsVested =                                      0;
	bountyBalance =                875000000000000000000000;
	dtUtils = new DateTime();
    }


    function () payable {
	buyCREDTokens(msg.sender);
    }

    function releaseFutureSale() onlyOwner public
    {
//	if (now > )
	balances[verifyWallet] = balances[verifyWallet] + tokenSaleBalance;
    
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
    
    function buyCREDTokens(address beneficiary) public payable {
	require(beneficiary != 0x0);
//	require(validPurchase());

        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

	if (now > tokensaleStartTime)
	{
	    if (earlyInvestorsBalance > 0)
	    {
		balances[verifyWallet] = balances[verifyWallet] + earlyInvestorsBalance;
		EarlyInvestorsBalanceReleased(msg.sender, "Tokens Transferres to verifyWallet",  earlyInvestorsBalance);
		earlyInvestorsBalance = 0;

	    }
	    sellTokens(tokens);
	    tokenSaleBalance.sub(tokens);
	    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
	    forwardFunds();
	    // update state
            weiRaised = weiRaised.add(weiAmount);

	}
	else 
/*	    if ((now > earlyTokensaleStartTime) && isInWhiteList(msg.sender))
	    {
		if ()
		{
		    balances[msg.sender] = balances[msg.sender] + tokens;
		    earlyInvestorsBalance -= tokens;
		    forwardFunds();

		}
	    }
*/	    {
		TokenSaleIsNotAllowed(msg.sender, "Refunded", msg.value);
		refundBack(msg.value);
	    }

    }

    function isInWhiteList(address addx) public onlyOwner returns (bool)
    {
	if (addx == whitelistAddresses.addxs[0]) return true;
	else return (whitelistAddresses.addxIndex[addx] != 0);
    }

    function forwardFunds() internal {
	verifyWallet.transfer(msg.value);
    }

    function refundBack(uint256 weis) internal {
	msg.sender.transfer(weis);
    }

    function sellTokens(uint256 tokens) internal
    {
	balances[verifyWallet] = balances[verifyWallet] - tokens;
	balances[msg.sender] = balances[msg.sender] + tokens;
    }

    event AddressAddedToWhiteList(address sender, uint16 index, address addx);
    function _AddAddressToWL(address addx) internal
    {
            whitelistAddresses.addxs[whitelistAddresses.size] = addx;
            whitelistAddresses.addxIndex[addx] = whitelistAddresses.size;
            AddressAddedToWhiteList(msg.sender, whitelistAddresses.size, addx);
            ++whitelistAddresses.size;
            
    }

    function _AddAddressToAL(address addx) internal
    {
            advisorsAddresses.addxs[advisorsAddresses.size] = addx;
            advisorsAddresses.addxIndex[addx] = advisorsAddresses.size;
            ++advisorsAddresses.size;
    }

    function _AddAddressToTL(address addx) internal
    {
            teamAddresses.addxs[teamAddresses.size] = addx;
            teamAddresses.addxIndex[addx] = teamAddresses.size;
            ++teamAddresses.size;
    }

    function setAddressVerifyed(address addx) onlyOwner public returns(bool)
    {
	isAddressVerified[addx] = true;
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
    function ListTeamAddresses() onlyOwner
    {
	for (uint16 i = 0; i < teamAddresses.size; ++i)
	{
	    ListWhitelist(msg.sender, i, teamAddresses.addxs[i]);
	}
    }

}
