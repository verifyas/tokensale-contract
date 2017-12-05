# Manual audit of the code

## Common issues
1. Migrations is not properly working and run with exceptions.
2. Migration flow is not covered by integration tests.
3. All contracts is merged `onefile.sol` manually, but this contract is not covered by test cases.
4. `gasPrice: 4 * 10**9 // 4 gwei` could be not enough to deploy contracts in the live network. Recommended value is 21-24 gwei.  

## CREDToken.sol

| Lines      | Code sample                                                     | Issue                                                                                                                                                                                  | Priority |
|------------|-----------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| 27, 28, 29 | address public teamWallet;                                      | Wallets is not a part of the ERC20 token contract                                                                                                                                      | Low      |
| 35, 36, 37 | uint256 teamLocked;                                             | Token locked values is not a part of the ERC20 token contract                                                                                                                          | Low      |
| 47         | TokenVesting public advisorsVesting = TokenVesting(address(0)); | Assignment does make no sense without proper arguments for TokenVesting                                                                                                                | Low      |
| 65         | modifier mintLockedOnlyOnce {                                   | Unused modifier                                                                                                                                                                        | Low      |
| 83-97      | function CREDToken(                                             | Wallets is not a part of the ERC20 token contract                                                                                                                                      | Low      |
| 130        | owner = 0;                                                      | Scheme without owner could leads to the tokens lost. Use this only if necessary.                                                                                                       | Low      |
| 138        | function unfreeze() public                                      | Possible you don't want to allow to call this method by anyone. Using timestamp dependence and allowance to call this method to anyone could lead to attack by timestamp manipulation. | High     |
| 154        | function unlockAdvisorTokens() public whenLiquid {              | Possible you don't want to allow to call this method by anyone. Using timestamp dependence and allowance to call this method to anyone could lead to attack by timestamp manipulation. | High     |


## Tokensale.sol

| Lines    | Code sample                                                                           | Issue                                                                                                            | Priority |
|----------|---------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|----------|
| 13-19    | uint256 constant public MAX_SUPPLY = 50000000 * 10 ** 18;                             | Token decimals could be taken from the constant.                                                                 | Low      |
| 23       | uint256 public soldDuringTokensale;                                                   | Variable is not used                                                                                             | Low      |
| 30       | event Prepurchased(address indexed recipient, uint256 etherPaid, uint256 tokensSold); | Event is not used                                                                                                | Low      |
| 58       | token = new CREDToken                                                                 | Crowdsale contract will be the owner of the token. Possible tokens lost.                                         | Low      |
| 76       | rate = SALE_TOKENS_SUPPLY.div(_cap);                                                  | Token price is dependent on the hardcap. It would be better to separate the price and hardcap in business logic. | Low      |
| 83       | for (uint256 i = 0; i < _wallets.length; i++) {                                       | Possible "out of gas" issue.                                                                                     | Low      |
| 98       | function finalise() public                                                            | Method could be called by anyone. Add onlyOwner modifier.                                                        | High     |
| 126, 136 | return validSalePurchase()                                                            | Remove dependency of conditions order.                                                                           | Medium   |

