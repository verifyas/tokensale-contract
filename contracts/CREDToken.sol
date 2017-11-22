pragma solidity ^0.4.4;

import "./math/SafeMath.sol";
import "./token/StandardToken.sol";
import "./ownership/Ownable.sol";
import "./lib/UniqueAddressSet.sol";

contract CREDToken is StandardToken, Ownable
{
    using SafeMath for uint256;

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
	bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
	bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
	string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
	bytes memory babcde = bytes(abcde);
        uint k = 0;
    
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

	for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

	for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);
    }
    
    function bytes32ToString (bytes32 data) internal returns (string) {
    bytes memory bytesString = new bytes(32);
    for (uint j=0; j<32; j++) {
      byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
      if (char != 0) {
        bytesString[j] = char;
      }
    }

    return string(bytesString);
  }
    
    function uintToBytes32(uint256 x) internal returns (bytes32 b) {
	assembly { mstore(add(b, 32), x) }
    }

    function uintToString(uint number) internal returns (string)
    {
	bytes32 bx32 = uintToBytes32(number);
	return bytes32ToString(bx32);
    }


    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
	return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
	return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
	return strConcat(_a, _b, "", "", "");
    }
    
    UniqueAddressSet public whitelistAddresses;
    UniqueAddressSet public advisorsAddresses;
    mapping (address => bool) public isAddressVerified;

    function CREDToken()
    {
	whitelistAddresses = new UniqueAddressSet();
	advisorsAddresses = new UniqueAddressSet();
    }
    
    function setAddressVerifyed(address addx) onlyOwner returns(bool)
    {
	isAddressVerified[addx] = true;
    }
    
    event AddToWhitelist(address sender, uint16 index, address addx);

    function AddAdressesToWhitelist(address[] addxs)
    {
	for (uint16 i = 0; i < addxs.length; ++i)
	{
	    AddToWhitelist(msg.sender, i, addxs[i]);
	    whitelistAddresses.addElement(addxs[i]);
	}
    }

    event ListWhitelist(address sender, uint16 index, address addx);
    function ListWhitelistAddresses() onlyOwner
    {
	for (uint16 i = 0; i < whitelistAddresses.getSize(); ++i)
	{
	    ListWhitelist(msg.sender, i, whitelistAddresses.getElement(i));
	}
    }

}
