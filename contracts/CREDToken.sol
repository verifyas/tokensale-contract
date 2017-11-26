pragma solidity ^0.4.4;

import "./math/SafeMath.sol";
import "./token/StandardToken.sol";
import "./ownership/Ownable.sol";
import "./lib/DateTime.sol";

contract CREDToken is StandardToken, Ownable
{

    string public constant name = "CRED";
    string public constant symbol = "CRED";
    uint8 public constant decimals = 18;

    using SafeMath for uint256;
    
    struct UniqueAddressSet
    {
	mapping (address => uint256) addxIndex;
	mapping (uint256 => address) addxs;
	uint256 size;
	mapping (uint256 => uint256) amount;
    }

    UniqueAddressSet public whitelistAddresses;

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

    uint256 public rate;
    uint256 public cap;
    uint256 public maxCap;
    address public verifyWallet;
    address public verifyFundWallet;
    address public miscellaneousWallet;
    address public futureTokenSaleWallet;
    address public verifyTeamWallet;
    address public advisorsWallet;
    uint256 public weiRaised;
    DateTime public dtUtils;
    
    uint256 public earlyTokensaleStartTime;
    uint256 public tokensaleStartTime;
    uint256 public futureTokensaleTime;
    uint256 public verifyTeamLockTime;
    uint256 public advisorsLockTime1;
//    uint256 public advisorsLockTime2;
    
    bool contractDeployed;
    bool capReached;
    
    function releaseLocked() onlyOwner public
    {
	if (now > futureTokensaleTime)
	{
	    balances[verifyWallet] = balances[verifyWallet] + balances[futureTokenSaleWallet];
	    balances[futureTokenSaleWallet] = 0;
	}

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
    

    function setVerifyWallet(address vwAddress) onlyOwner public
    {
	if (!contractDeployed)
	{
	    verifyWallet = vwAddress;
	}    
    }

    function setVerifyFundWallet(address vwfAddress) onlyOwner public
    {
	if (!contractDeployed)
	{
	    verifyFundWallet = vwfAddress;
	}    
    }

    function setVerifyTeamWallet(address Address) onlyOwner public
    {
	if (!contractDeployed)
	{
	    verifyTeamWallet = Address;
	}    
    }

    function setVerifyAdvisorsWallet(address Address) onlyOwner public
    {
	if (!contractDeployed)
	{
	    advisorsWallet = Address;
	}    
    }

    function setVerifyMiscWallet(address Address) onlyOwner public
    {
	if (!contractDeployed)
	{
	    miscellaneousWallet = Address;
	}    
    }

    function setConversionRate(uint256 cRate) onlyOwner public
    {
	if (!contractDeployed)
	{
	    rate = cRate;
	}    
    }
    
    function lockContract() public onlyOwner
    {
	contractDeployed = true;
    }

    function CREDToken()
    {
	dtUtils = new DateTime();
    }

    function InitializeToken() public onlyOwner
    {
	contractDeployed = false;
	weiRaised = 0;
	maxCap =                         	    8345000000000000000000;
	totalSupply =                		50000000000000000000000000;
	cap =                            	    1666000000000000000000;
	
	balances[verifyFundWallet] = 		10500000000000000000000000;
	balances[verifyWallet] =     		11125000000000000000000000;

	balances[miscellaneousWallet] =       	 2875000000000000000000000;
	balances[futureTokenSaleWallet] =     	10000000000000000000000000;
	balances[verifyTeamWallet] =          	10000000000000000000000000;
	balances[advisorsWallet] =             	 5500000000000000000000000;
    }

    function deployToProduction() public onlyOwner
    {
	rate = 1333;
	weiRaised = 0;
	verifyWallet = 0xB4e817449b2fcDEc82e69f02454B42FE95D4d1fD;
	verifyFundWallet = 0x028e27D09bb37FA00a1691fFE935D190C8D1668c;
	miscellaneousWallet =       0x7F744e420874AF3752CE657181e4b37CA9594779;
	futureTokenSaleWallet =     0xb30CC06c46A0Ad3Ba600f4a66FB68F135EAb716D;
	verifyTeamWallet = 0xC29789f465DF1AAF791027f4CABFc6Eb3EC2fc19;
	advisorsWallet = 0x14589ba142Ff8686772D178A49503D176628147a;
	
	maxCap =                         8345000000000000000000;
	totalSupply =                50000000000000000000000000;
	cap =                            1666000000000000000000;
	
	InitializeToken();

	setEarlyTokenSaleTime(2017, 11, 28, 2, 0);
	setTokensaleTime(2017, 11, 29, 2, 0);
	setFutureTokensaleTime(2018, 11, 29, 2, 0);
	setVerifyTeamLockTime(2018, 11, 29, 2, 0);
	setAdvisorsLockTime1(2018, 2, 29, 2, 0);
	contractDeployed = false;
    }
    
    function () payable {
	if (msg.sender != verifyWallet) buyCREDTokens(msg.sender);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
	bool nonZeroPurchase = msg.value != 0;
	return nonZeroPurchase;
    }
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event TokenSaleIsNotAllowed(address sender, string message, uint256 amount);
    event OutOfTokens(address sender, string message, uint256 lastPurchase);
    event WLTokensLimitReached(address sender, string message, uint256 lastPurchase);
    event HardCapReached(address sender, string message, string message2);
    event Debug(address sender, uint256 spent, uint256 amount, int256 left);

    function buyCREDTokens(address beneficiary) internal {
	require(beneficiary != 0x0);
//	require(validPurchase());
	uint256 tokenDiff = 0;
        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

	if (weiRaised >= maxCap)
	{
		TokenSaleIsNotAllowed(msg.sender, "Refunded", msg.value);
		HardCapReached(msg.sender, "HardCap", " Reached");
		refundBack(msg.value);
	}

	if (now > tokensaleStartTime)
	{

	    if (tokens > balances[verifyWallet])
	    {
		OutOfTokens(msg.sender, "VerifyWallet out of tokens", tokens);
		tokenDiff = tokens - balances[verifyWallet];
		tokens = balances[verifyWallet];
	    }

	    sellTokens(tokens);
	    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

	    uint256 weiResult = forwardOrRefund(tokenDiff);
	    if (isInCustomerList(msg.sender)) _UpdateCustomer (msg.sender, weiResult, tokens);
	    else _AddNewCustomer (msg.sender, weiResult, tokens);
	}
	else 
	    if ((now > earlyTokensaleStartTime) && isInWhiteList(msg.sender))
	    {

		uint256 cIndex = customerInfo.addxIndex[msg.sender];
		uint256 wlIndex = whitelistAddresses.addxIndex[msg.sender];

		int256 tokensLeft = (int256(whitelistAddresses.amount[wlIndex]) - int256(customerInfo.weiSpent[cIndex]))*int256(rate);

		Debug(msg.sender, whitelistAddresses.amount[wlIndex], customerInfo.weiSpent[cIndex], tokensLeft);
		if (tokensLeft < 0)
		{
		    refundBack(msg.value);
		    return;
		}

		tokenDiff = 0;
		if (int256(tokens) > tokensLeft)
		{
		    tokenDiff = tokens - uint256(tokensLeft);
		    tokens = uint256(tokensLeft);
		}

		if (tokens > balances[verifyWallet])
		{
		    OutOfTokens(msg.sender, "VerifyWallet out of tokens", tokens);

		    tokenDiff = tokens - balances[verifyWallet] + tokenDiff;

		    tokens = balances[verifyWallet];
		}

		sellTokens(tokens);
		TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        	//customerInfo.weiSpent[cIndex] = customerInfo.weiSpent[cIndex] + forwardOrRefund(tokenDiff);
		
		uint256 weiDiff = forwardOrRefund(tokenDiff);
		
		if (isInCustomerList(msg.sender)) _UpdateCustomer (msg.sender, weiDiff, tokens);
		else _AddNewCustomer (msg.sender, weiDiff, tokens);

	    }
	    else
	    {
		TokenSaleIsNotAllowed(msg.sender, "Refunded", msg.value);
		refundBack(msg.value);
	    }

    }

    function forwardOrRefund(uint256 tokenDiff) internal returns (uint256)
    {
    	    uint256 weiDiff = 0;
    	    uint256 weiRefund = 0;
	    if (tokenDiff > 0)
	    {
		weiRefund = tokenDiff.div(rate);
		refundBack(weiRefund);
	    }
	    weiDiff = msg.value - weiRefund;
	    forwardFunds(weiDiff);
	    // update state
            weiRaised = weiRaised.add(weiDiff);
            return weiDiff;
    }
    
    function isInWhiteList(address addx) internal returns (bool)
    {
	if (addx == whitelistAddresses.addxs[0]) return true;
	else return (whitelistAddresses.addxIndex[addx] != 0);
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

    event AddressAddedToWhiteList(address sender, uint256 index, address addx);
    function _AddAddressToWL(address addx, uint256 amount) internal
    {
            whitelistAddresses.addxs[whitelistAddresses.size] = addx;
            whitelistAddresses.addxIndex[addx] = whitelistAddresses.size;
            whitelistAddresses.amount[whitelistAddresses.size] = amount;
            AddressAddedToWhiteList(msg.sender, whitelistAddresses.size, addx);
            ++whitelistAddresses.size;
	    _AddNewCustomer(addx, 0, 0);
	    setAddressVerified(addx);
    }

    function setAddressVerified(address addx) onlyOwner public
    {
	uint256 cIndex;
	if (isInCustomerList(addx))
	{
	    cIndex = customerInfo.addxIndex[addx];
	    customerInfo.isVerified[cIndex] = true;
	}
	else
	{
	    _AddNewCustomer(addx, 0, 0);
	    cIndex = customerInfo.addxIndex[addx];
	    customerInfo.isVerified[cIndex] = true;
	    
	}
    }

    function isAddressVerified(address addx) onlyOwner public returns(bool)
    {
	uint256 cIndex = customerInfo.addxIndex[addx];
	return customerInfo.isVerified[cIndex];

    }
    event AddTolist(address addx, string listname, uint256 index);
    event AddressAlreadyInList(address sender, string message, string listname);
    event AddressArrayAndAmountArraysMustBeEqual(address sender, uint256 lengthAddresses, uint256 lengthAmounts);
    function AddAdressesToWhitelist(address[] addxs, uint256[] amounts) onlyOwner
    {
	if (amounts.length != addxs.length)
	{
	    AddressArrayAndAmountArraysMustBeEqual(msg.sender, addxs.length, amounts.length);
	    return;
	}
	for (uint256 i = 0; i < addxs.length; ++i)
	{
	    AddTolist(addxs[i], "Whitelist", i);
	    if (whitelistAddresses.size == 0)
	    {
		_AddAddressToWL(addxs[i], amounts[i]);
	    }
    	    else {
    		if (whitelistAddresses.addxIndex[addxs[i]] == 0 && whitelistAddresses.addxs[0] != addxs[i])
    		{
		    _AddAddressToWL(addxs[i], amounts[i]);
    		}
    		else AddressAlreadyInList(msg.sender, "Address already in ", "Whitelist");
    	    }

	}
    }

    event ListWhitelist(address sender, uint256 index, address addx, uint256 amount);
    function ListWhitelistAddresses() onlyOwner public
    {
	for (uint256 i = 0; i < whitelistAddresses.size; ++i)
	{
	    ListWhitelist(msg.sender, i, whitelistAddresses.addxs[i], whitelistAddresses.amount[i]);
	}
    }
    
/* Rufund function.
    event weiRefunded(address sender, address recipient, uint256 amount);
    function refundCapNotReached() public
    {
	if (msg.sender == verifyWallet)
	if (weiRaised < cap)
	{
	    for (uint256 i = 0; i < customerInfo.size; ++i)
	    {
		address recipient = customerInfo.addxs[i];
		uint amount = customerInfo.weiSpent[i];
		recipient.transfer(amount);
		weiRefunded(msg.sender, recipient, amount);
	    }
	}
    }
*/

    event weiRefunded(address sender, address recipient, uint256 amount);
    function refundForNotVerified(address Address) public onlyOwner
    {
//	if (msg.sender == verifyWallet)
	    if (!isAddressVerified(Address))
	    {
		uint256 cIndex = customerInfo.addxIndex[Address];
		uint256 amount = customerInfo.weiSpent[cIndex];
		Address.transfer(amount);
		balances[verifyWallet] += balances[Address];
		balances[Address] = 0;
	    
		weiRefunded(msg.sender, Address, amount);
	    }
    }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(isAddressVerified(msg.sender));
    if ((msg.sender == verifyTeamWallet) && now < verifyTeamLockTime) return false;
    if ((msg.sender == advisorsWallet) && now < advisorsLockTime1) return false;

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }


}
