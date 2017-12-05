# Migration log

Migration produces errors on testrpc. 

```
$ ./node_modules/.bin/truffle migrate
Using network 'development'.

Running migration: 1_initial_migration.js
Saving artifacts...
Running migration: 2_deploy_contracts.js
Deploying sales contract. Please confirm transaction.
Saving artifacts...
  ... 0x98d9b76aeddb04d5a2574ab18e5d24f541c422eeef128608b8ec0d480ba74396
Error: VM Exception while processing transaction: revert
    at Object.InvalidResponse (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:43303:16)
    at /Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:331156:36
    at /Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:175492:11
    at /Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:314196:9
    at XMLHttpRequest.request.onreadystatechange (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:315621:13)
    at XMLHttpRequestEventTarget.dispatchEvent (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70159:18)
    at XMLHttpRequest._setReadyState (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70449:12)
    at XMLHttpRequest._onHttpResponseEnd (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70604:12)
    at IncomingMessage.<anonymous> (/Users/derain/Projects/smartcont/node_modules/truffle/build/cli.bundled.js:70564:24)
    at emitNone (events.js:110:20)
```    

### Migrations issues
| Pointer to the issue (file path : number of string) | Code sample                     | Issue                                                                    | Priority |
|-----------------------------------------------------|---------------------------------|--------------------------------------------------------------------------|----------|
| migrations/1_initial_migration.js : 4               | // deployer.deploy(Migrations); | Migrations contract should be deployed first. Migrations is not working. | High    |