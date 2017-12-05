pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/token/TokenVesting.sol';


contract MonthlyTokenVesting is TokenVesting {

    uint256 public previousTokenVesting = 0;

    function MonthlyTokenVesting(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        bool _revocable
    ) public
    TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    { }


    function release(ERC20Basic token) public onlyOwner {
        require(now >= previousTokenVesting + 30 days);
        super.release(token);
        previousTokenVesting = now;
    }
}
