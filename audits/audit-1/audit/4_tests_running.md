# Test run log

All tests running correctly. Error provided by the migration.

```bash

  Contract: TokenSale
Error: VM Exception while processing transaction: invalid opcode
    at Object.InvalidResponse (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:43303:16)
    at /Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:331156:36
    at /Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:175492:11
    at /Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:314196:9
    at XMLHttpRequest.request.onreadystatechange (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:329855:7)
    at XMLHttpRequestEventTarget.dispatchEvent (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70159:18)
    at XMLHttpRequest._setReadyState (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70449:12)
    at XMLHttpRequest._onHttpResponseEnd (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70604:12)
    at IncomingMessage.<anonymous> (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70564:24)
    at emitNone (events.js:110:20)
    Before presale
      ✓ should setup token
      ✓ should calculate rate
      ✓ should correctly set token allocations (178ms)
      ✓ non-owner should not able to add presale accounts
      ✓ should be possible for owner to change cap (80ms)
      ✓ non-owner cannot change cap
      ✓ should not be possible to take part in presales
    During presale
      ✓ presale should work (267ms)
      ✓ not possible to change hardcap
      ✓ not possible to buy if not in whitelist
      ✓ should not presale over cap (464ms)
      ✓ should not presale over cap while adding (460ms)
      ✓ cannot buy over limit (124ms)
      ✓ limit behaves correctly when value has many decimal digits (76ms)
      ✓ tokens should be frozen (73ms)
      ✓ should be finalisable if hard cap reached (547ms)
      ✓ presale tokens transferable week after finalization (670ms)
    During Sale
      ✓ should be possible to buy (92ms)
      ✓ should not be possible to buy over hard cap (513ms)
      ✓ tokens should be frozen (85ms)
      ✓ should not be possible to pause if not owner
      ✓ should not be possible to finalise
      ✓ should be finalisable after hard cap reached (567ms)
      Paused
        ✓ should not be possible to buy
        ✓ not owner should not be able to unpause
        ✓ should buy tokens after unpause (97ms)
      After sale
        ✓ should be finalised
        ✓ should not be possible to buy (40ms)
        ✓ should not be unfreezable
        Unfrozen tokens
          ✓ tokens should be unfreezable after a week (57ms)
          ✓ investment wallet and misc. wallet transferable (90ms)
          ✓ team and reserve not transferable (44ms)
          ✓ team and reserve transferable after a year (104ms)

  Contract: CREDToken
    Minting
      ✓ should not transfer
      ✓ should not approve transfer
      ✓ should not mint more than cap
      ✓ not owner should not be able to mint
      ✓ should add when minting (59ms)
      ✓ should not be able to mint locked twice (149ms)
      ✓ only owner should be able to finalise
    Frozen
      ✓ should compute total supply
      ✓ owner is 0x0
      ✓ should not be able to unfreeze tokens right after tokensale ends
      ✓ should not be able to transfer frozen tokens
      ✓ should not be able to finalise twice
      ✓ should not be able to unlock tokens right after sale
    Liquid
      ✓ should be able to transfer frozen tokens (106ms)
      ✓ should not be able to unlock team and reserve tokens
      Reserve and team
        ✓ should be able to unlock all reserve tokens after a year (209ms)
        ✓ should be able to unlock reserve tokens only once (263ms)
      Advisors
        ✓ not unlockable 1 week after sale end
        ✓ can unlock only once during one cliff (152ms)
        ✓ should unlock all after 2 years (602ms)


  53 passing (33s)
```