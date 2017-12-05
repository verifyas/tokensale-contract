# Verify Smart Contract

**Important Note**: The primary audit report will be added shortly.

## Requirements

The below requirements describe the behavior that this smart contract adheres to.

### General Attributes

- Token Name: CRED
- Fully ERC-20 compliant
- Total Supply: 50,000,000 CRED tokens

### Token Allocation

The 50,000,000 CRED tokens will be allocated according to the below table:

| Tokens | Purpose | Lockup Period |
|-------:|:--------|:--------------|
| 11,125,000 | Tokensale | After end of tokensale by 1 week |
| 10,5000,000 | Verify Fund (single wallet) | Until end of tokensale |
| 2,875,000 | Miscellaneous (bounty, early investors) | Until end of tokensale |
| 10,000,000 | Verify Team (single wallet) |  Until 1 year after start of tokensale |
| 10,000,000 | Reserved for future tokensale (single wallet) | Until 1 year after start of tokensale |
| 5,500,000 | Advisors (single wallet) | Vests over 2 years, with a 3 month cliff |
| **50,000,000** | |

The ETH raised from the tokensale will be stored in an external wallet, with an address that will be provided. Wallet addresses will be provided for each of the rows in the table above.

### Tokensale Details

The tokensale consists of a pre-sale as well as a public sale. The pre-sale begins 1 day before the public sale, and is available only to specific ETH addresses up to a specific ETH contribution limit -- there is a list of about 500 addresses (and amounts) in total.

#### Tokensale attributes:

- Tokens available for sale: 11,125,000 CRED tokens
- Presale start Date: Dec 6, 2017 at 2pm UTC
- Public Start Date: Dec 7, 2017 at 2pm UTC
- End Date: Jan 7, 2018 (30 days later)
- Hard cap: 5,000 ETH (if the hard cap is reached, the tokensale ends immediately)
- Rate (from CRED -> ETH) can be found using the formula:
  - tokensale allocation / hard cap = 11,125,000 / 5000 = 2,225 CRED / ETH
- The hard cap in ETH will be set just before the tokensale starts, so the rate calculation will be updated automatically after it is set
- Tokens will be frozen until 1 week after the tokensale is completed
