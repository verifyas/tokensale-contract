pragma solidity ^0.4.4;

contract UniqueAddressSet
{
    event SetOutOfRange(address addx, string message, uint elementIndex);

    mapping (uint => address) addxs;
    mapping (address => uint) addxIndex;
    uint public size = 0;
    
    function UniqueAddressSet()
    {

    }
    
    function _addElement(address addx) internal
    {
	addxs[size] = addx;
	addxIndex[addx] = size;
	++size;
    }

    function addElement(address addx)
    {
	if (size == 0) _addElement(addx);
	else if (addxIndex[addx] == 0) _addElement(addx);
    }
    
    function getElement(uint elementIndex) returns (address)
    {
	if (elementIndex >= size) 
	{
	    SetOutOfRange(msg.sender, "Set Out of range", elementIndex);
	    return 0;
	}
	else return addxs[elementIndex];
    }

    function getSize() returns (uint)
    {
	return size;
    }
    
}