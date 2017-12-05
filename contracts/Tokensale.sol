pragma solidity ^0.4.18;


import './CREDToken.sol';
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';


contract Tokensale is CappedCrowdsale, Pausable{
    using SafeMath for uint256;

    uint256 constant public MAX_SUPPLY = 50000000 ether;
    uint256 constant public SALE_TOKENS_SUPPLY = 11125000 ether;
    uint256 constant public INVESTMENT_FUND_TOKENS_SUPPLY = 10500000 ether;
    uint256 constant public MISCELLANEOUS_TOKENS_SUPPLY = 2875000 ether;
    uint256 constant public TEAM_TOKENS_SUPPLY = 10000000 ether;
    uint256 constant public RESERVE_TOKENS_SUPPLY = 10000000 ether;
    uint256 constant public ADVISORS_TOKENS_SUPPLY = 5500000 ether;


    uint256 public totalSold;
    uint256 public soldDuringTokensale;

    uint256 public presaleStartTime;

    mapping(address => uint256) public presaleLimit;


    modifier beforeSale() {
        require(now < startTime);
        _;
    }

    modifier duringSale() {
        require(now >= startTime && !hasEnded() && !paused);
        _;
    }

    function Tokensale(
        uint256 _presaleStartTime,
        uint256 _startTime,
        uint256 _hardCap,
        address _investmentFundWallet,
        address _miscellaneousWallet,
        address _treasury,
        address _teamWallet,
        address _reserveWallet,
        address _advisorsWallet
    )
    CappedCrowdsale(_hardCap)
    Crowdsale(_startTime, _startTime + 30 days, SALE_TOKENS_SUPPLY.div(_hardCap), _treasury)
    public
    {
        require(_startTime > _presaleStartTime);
        require(now < _presaleStartTime);

        token = new CREDToken(
            MAX_SUPPLY,
            _startTime + 1 years,
            _teamWallet,
            _reserveWallet,
            _advisorsWallet
        );
        presaleStartTime = _presaleStartTime;
        mintInvestmentFundAndMiscellaneous(_investmentFundWallet, _miscellaneousWallet);
        castedToken().mintTeamTokens(TEAM_TOKENS_SUPPLY);
        castedToken().mintReserveTokens(RESERVE_TOKENS_SUPPLY);
        castedToken().mintAdvisorsTokens(ADVISORS_TOKENS_SUPPLY);

    }

    function setHardCap(uint256 _cap) public onlyOwner {
        require(now < presaleStartTime);
        require(_cap > 0);
        cap = _cap;
        rate = SALE_TOKENS_SUPPLY.div(_cap);
    }

    // Function for setting presale buy limits for list of accounts
    function addPresaleWallets(address[] _wallets, uint256[] _weiLimit) external onlyOwner {
        require(now < startTime);
        require(_wallets.length == _weiLimit.length);
        for (uint256 i = 0; i < _wallets.length; i++) {
            presaleLimit[_wallets[i]] = _weiLimit[i];
        }
    }

    // Override to track sold tokens
    function buyTokens(address beneficiary) public payable {
        super.buyTokens(beneficiary);
        // If bought in presale, decrease limit
        if (now < startTime) {
            presaleLimit[msg.sender] = presaleLimit[msg.sender].sub(msg.value);
        }
        totalSold = totalSold.add(msg.value.mul(rate));
    }

    function finalise() public {
        require(hasEnded());
        castedToken().finalise();
    }

    function mintInvestmentFundAndMiscellaneous(
        address _investmentFundWallet,
        address _miscellaneousWallet
    ) internal {
        require(_investmentFundWallet != address(0));
        require(_miscellaneousWallet != address(0));

        token.mint(_investmentFundWallet, INVESTMENT_FUND_TOKENS_SUPPLY);
        token.mint(_miscellaneousWallet, MISCELLANEOUS_TOKENS_SUPPLY);
    }

    function castedToken() internal view returns (CREDToken) {
        return CREDToken(token);
    }

    // Overrides Crowdsale#createTokenContract not to create new token
    // CRED Token is created in the constructor
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(address(0));
    }

    function validSalePurchase() internal view returns (bool) {
        return super.validPurchase();
    }

    function validPreSalePurchase() internal view returns (bool) {
        if (msg.value > presaleLimit[msg.sender]) { return false; }
        if (weiRaised.add(msg.value) > cap) { return false; }
        if (now < presaleStartTime) { return false; }
        if (now >= startTime) { return false; }
        return true;
    }

    // Overrides CappedCrowdsale#validPurchase to check if not paused
    function validPurchase() internal view returns (bool) {
        require(!paused);
        return validSalePurchase() || validPreSalePurchase();
    }

}
