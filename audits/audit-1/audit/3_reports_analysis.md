# Reports analysis

## Solhint

Highlighted issues provided by the [report](../report/solhint/report)  
 
#### CREDToken.sol

| Line | Column | Type    | Message                             |
|------|--------|---------|-------------------------------------|
| 1    | 17     | warning | Compiler version must be fixed      |
| 35   | 5      | warning | Explicitly mark visibility of state |
| 36   | 5      | warning | Explicitly mark visibility of state |
| 37   | 5      | warning | Explicitly mark visibility of state |

#### Tokensale.sol

| Line | Column | Type    | Message                             |
|------|--------|---------|-------------------------------------|
| 1    | 17     | warning | Compiler version must be fixed      |


## Oyente security tool
Report provided assertion and timestamp failures. Assertion failures is covered 
by ```SafeMath``` library, but all timestamp dependencies should be checked manually and
highlighted in manual audit report if needed

