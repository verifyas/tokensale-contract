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

  // Storage unit for individual whitelisted address
  struct UniqueAddressSet
  {
    mapping (address => uint256) addxIndex; // get index for an address
    mapping (uint256 => address) addxs; // get address at index
    uint256 size;
    mapping (uint256 => uint256) amount; // get amount at index
  }
  UniqueAddressSet public whitelistAddresses;

  // Storage unit for KYC'd addresses
  struct KYCAddressSet
  {
     mapping (address => uint256) addxIndex; // get customerInfo index from an address
     mapping (uint256 => address) addxs; // get address from index
     uint256 size; // tail pointer
     mapping (uint256 => bool) isVerified; // is this address verified?
     mapping (uint256 => uint256) weiSpent; // tracks total wei spent by address
     mapping (uint256 => uint256) tokensPurchased; // tracks token purchases
     mapping (uint256 => uint256) lastPurchaseTimestamp;
  }
  KYCAddressSet customerInfo;

  function isInCustomerList(address addx) internal returns (bool) /* TODO: Why no '_' prefix for this internal function? */
  {
    /* does this address belong to an existing customer? */
    if (addx == customerInfo.addxs[0]) return true; /* TODO: Why this check? */
    else return (customerInfo.addxIndex[addx] != 0); // does entry exist?
  }

  function _AddNewCustomer(address addx, uint256 weiSpent, uint256 tokensPurchased) internal
  {
    /* create new customerInfo object and append to list */
    customerInfo.addxs[customerInfo.size] = addx;
    customerInfo.weiSpent[customerInfo.size] = weiSpent;
    customerInfo.tokensPurchased[customerInfo.size] = tokensPurchased;
    customerInfo.lastPurchaseTimestamp[customerInfo.size] = now;
    customerInfo.addxIndex[addx] = customerInfo.size;
    ++customerInfo.size;
  }

  function _UpdateCustomer(address addx, uint256 weiSpent, uint256 tokensPurchased) internal
  {
    /* udpate details for a particular customer; can only contribute more, not less */
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

  bool contractDeployed;
  bool capReached;

  function releaseLocked() onlyOwner public
  {
    /* releases tokens that are locked for future tokensale, after lock period has lapsed  */
    if (now > futureTokensaleTime)
    {
      balances[verifyWallet] = balances[verifyWallet] + balances[futureTokenSaleWallet];
      balances[futureTokenSaleWallet] = 0;
    }
  }

  /* you can either deploy using the below setters or using deployToProduction() below */
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
  { /* TODO: Change to setAdvisorsLockTime (remove '1') */
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
    /* constructor */
    dtUtils = new DateTime();
  }

  function InitializeToken() public onlyOwner
  {
    /* TODO: These caps need to be set 24 hours before the tokensale date */
    contractDeployed = false;
    weiRaised = 0;

    cap =               1666000000000000000000; // soft cap: 1,666 ETH
    maxCap =            8345000000000000000000; // hard cap: 8,345 ETH
    totalSupply =   50000000000000000000000000; // 50,000,000 CREDs

    /* CRED allocations, made according to white paper */
    balances[verifyWallet] =          11125000000000000000000000; // 11,125,000
    balances[verifyFundWallet] =      10500000000000000000000000; // 10,500,000
    balances[futureTokenSaleWallet] = 10000000000000000000000000; // 10,000,000
    balances[verifyTeamWallet] =      10000000000000000000000000; // 10,000,000
    balances[advisorsWallet] =         5500000000000000000000000; //  5,500,000
    balances[miscellaneousWallet] =    2875000000000000000000000; //  2,875,000
    /*                                        |----------------|  */
  }

  function deployToProduction() public onlyOwner
  {
    /**
     * sets default values for the contract and deploys the contract (as an
     * alternative to setting manually using setters)
     **/
    rate = 1333; // default CREDs/ETH rate
    weiRaised = 0;
    verifyWallet =              0xB4e817449b2fcDEc82e69f02454B42FE95D4d1fD;
    verifyFundWallet =          0x028e27D09bb37FA00a1691fFE935D190C8D1668c;
    miscellaneousWallet =       0x7F744e420874AF3752CE657181e4b37CA9594779;
    futureTokenSaleWallet =     0xb30CC06c46A0Ad3Ba600f4a66FB68F135EAb716D;
    verifyTeamWallet =          0xC29789f465DF1AAF791027f4CABFc6Eb3EC2fc19;
    advisorsWallet =            0x14589ba142Ff8686772D178A49503D176628147a;

    maxCap =                         8345000000000000000000;
    totalSupply =                50000000000000000000000000;
    cap =                            1666000000000000000000;

    InitializeToken(); /* TODO: won't this override the values set above? */

    setEarlyTokenSaleTime(2017, 11, 28, 2, 0); // UTC
    setTokensaleTime(2017, 11, 29, 2, 0);
    setFutureTokensaleTime(2018, 11, 29, 2, 0); // at least 12 months out
    setVerifyTeamLockTime(2018, 11, 29, 2, 0); // at least 12 months out
    setAdvisorsLockTime1(2018, 2, 28, 2, 0); // 3 month cliff
    contractDeployed = false;
  }

  function () payable {
    /* allows someone to buy CRED tokens */
    if (msg.sender != verifyWallet) buyCREDTokens(msg.sender);
    /* TODO: Question, what about 'else' */
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
//  require(validPurchase()); /* TODO: why is this commented out? */
    uint256 tokenDiff = 0;
    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // have we already hit the hard cap?
    if (weiRaised >= maxCap)
    {
      TokenSaleIsNotAllowed(msg.sender, "Refunded", msg.value);
      HardCapReached(msg.sender, "HardCap", " Reached");
      refundBack(msg.value);
    }

    if (now > tokensaleStartTime)
    {
      // public tokensale active
      if (tokens > balances[verifyWallet])
      {
        // The verify wallet has no more tokens to distribute; hard cap reached
        OutOfTokens(msg.sender, "VerifyWallet out of tokens", tokens); /* TODO: Isn't this hard-cap reached state too? */
        tokenDiff = tokens - balances[verifyWallet];
        tokens = balances[verifyWallet];
      }

      // Sell remaining tokens
      sellTokens(tokens);
      TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

      // Refund the excess funds in wei
      uint256 weiResult = forwardOrRefund(tokenDiff);

      // Update customerInfo
      if (isInCustomerList(msg.sender)) _UpdateCustomer(msg.sender, weiResult, tokens);
      else _AddNewCustomer(msg.sender, weiResult, tokens);
    }
    else
    {
      if ((now > earlyTokensaleStartTime) && isInWhiteList(msg.sender))
      {
        // Whitelist sales has started, whitelisted member contributing
        uint256 cIndex = customerInfo.addxIndex[msg.sender];
        uint256 wlIndex = whitelistAddresses.addxIndex[msg.sender];

        int256 tokensLeft = (int256(whitelistAddresses.amount[wlIndex]) - int256(customerInfo.weiSpent[cIndex]))*int256(rate);
        /* whitelistAddresses.amount[wlIndex] => the contribution cap in wei for this address */
        /* customerInfo.weiSpent[cIndex]      => total wei spent by this address */
        /* (cap - wei spent) * rate would only be -ve if there was overspend */
        /* it would be +ve if there was some room left for buying tokens  */

        Debug(msg.sender, whitelistAddresses.amount[wlIndex], customerInfo.weiSpent[cIndex], tokensLeft);

        /* TODO: BUG: Why is this check done *before* the current transaction amount is considered?
            There should be no possible scenario where the wei spent is greater than the cap */
        if (tokensLeft < 0)
        {
          refundBack(msg.value);
          return;
        }

        tokenDiff = 0;
        if (int256(tokens) > tokensLeft)
        {
          // The whitelisted customer is trying to purchase tokens beyond the cap;
          // Accept up to the cap, and store the excess in tokenDiff
          tokenDiff = tokens - uint256(tokensLeft);
          tokens = uint256(tokensLeft);
        }

        if (tokens > balances[verifyWallet])
        {
          // Are their enough remaining tokens to fulfill this purchase?
          OutOfTokens(msg.sender, "VerifyWallet out of tokens", tokens);

          // Accept up to the amount remaining in the verifyWallet, and add the
          // excess to tokenDiff
          tokenDiff = tokens - balances[verifyWallet] + tokenDiff;
          tokens = balances[verifyWallet];
        }

        sellTokens(tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        //customerInfo.weiSpent[cIndex] = customerInfo.weiSpent[cIndex] + forwardOrRefund(tokenDiff);

        uint256 weiDiff = forwardOrRefund(tokenDiff); /* TODO: Come back to this after inspecting forwardOrRefund */

        // weiDiff holds the actual contribution amount (original - refunded amount)
        if (isInCustomerList(msg.sender)) _UpdateCustomer (msg.sender, weiDiff, tokens);
        else _AddNewCustomer (msg.sender, weiDiff, tokens);
      }
      else
      {
        // pre-sale hasn't started OR not whitelisted
        TokenSaleIsNotAllowed(msg.sender, "Refunded", msg.value);
        refundBack(msg.value);
      }
    }
  }

  function forwardOrRefund(uint256 tokenDiff) internal returns (uint256)
  {
    uint256 weiDiff = 0;
    uint256 weiRefund = 0;

    if (tokenDiff > 0)
    {
      // excess tokens that need to be returned
      weiRefund = tokenDiff.div(rate);
      refundBack(weiRefund);
    }

    // forward the funds on to the tokensale wallet
    weiDiff = msg.value - weiRefund;
    forwardFunds(weiDiff); /* TODO: Come back after reviewing forwardFunds */

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
    /* pass the funds on to the Verify wallet */
    verifyWallet.transfer(val);
  }

  event WeiRefunded(address sender, string message, uint256 amount);
  function refundBack(uint256 weis) internal {
    msg.sender.transfer(weis);
    WeiRefunded(msg.sender, "Refunded: ", weis);
  }

  function sellTokens(uint256 tokens) internal
  {
    /* transfers tokens from the verifyWallet to the msg sender */
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

  /**
   * address verification is concerned with allowing the free transfer of tokens
   * for those that have already been KYC'd.
   */
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
      // mismatch in input data -- amounts must match addresses
      AddressArrayAndAmountArraysMustBeEqual(msg.sender, addxs.length, amounts.length);
      return;
    }
    for (uint256 i = 0; i < addxs.length; ++i)
    {
      AddTolist(addxs[i], "Whitelist", i);
      if (whitelistAddresses.size == 0)
      {
        // whitelist empty, no need to check for dups
        _AddAddressToWL(addxs[i], amounts[i]);
      }
      else
      {
        // whitelist not empty
        if (whitelistAddresses.addxIndex[addxs[i]] == 0 && whitelistAddresses.addxs[0] != addxs[i])
        {
          // hasn't already been added
          _AddAddressToWL(addxs[i], amounts[i]);
        }
        else
        {
          AddressAlreadyInList(msg.sender, "Address already in ", "Whitelist");
        }
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

  event weiRefunded(address sender, address recipient, uint256 amount);
  function refundForNotVerified(address Address) public onlyOwner
  {
    // A method to refund those that contributed but could not later be verified
    // i.e. did not pass KYC
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
    // allows transfers between any two accounts, as long as the sender is
    // verified (i.e. passed KYC)

    require(_to != address(0)); // prevent accidental burning of tokens
    require(isAddressVerified(msg.sender)); // only allow verified senders

    if ((msg.sender == verifyTeamWallet) && now < verifyTeamLockTime) return false;
    if ((msg.sender == advisorsWallet) && now < advisorsLockTime1) return false;

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value); /* TODO: BUG Where is the Transfer event defined? */
    return true;
  }
}
