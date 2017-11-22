pragma solidity ^0.4.4;

contract UniqueAddressSet
{
    event SetOutOfRange(address addx, string message, uint elementIndex);
    event UniqueAddressSetDebug(address addx, string functionName, string message);
    event Debug(address sender, address adx, uint sz );
    
    mapping (address => uint16) addxIndex;
    mapping (uint16 => address) addxs;
    uint16 public size;

    function UniqueAddressSet()
    {
	UniqueAddressSetDebug(msg.sender, "Constructor", "Reached");
	size = 0;
    }
    
    function _addElement(address addx) internal
    {
	if (size == 0)
	{
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached");
	    addxs[size] = addx;
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached2");
	    addxIndex[addx] = size;
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached3");
	    ++size;
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached4");
	}
	else
	{
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached5");
	    addxs[size] = addx;
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached6");
	    Debug(msg.sender, addx, size);
	    addxIndex[addx] = 1;
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached7");
	    ++size;
	    UniqueAddressSetDebug(msg.sender, "_addElement", "Reached8");

	}
	
    }

    function addElement(address addx)
    {
	UniqueAddressSetDebug(msg.sender, "Add Element", "Reached, line 27");
	if (size == 0) _addElement(addx);
	else if (addxIndex[addx] == 0)
	{
		UniqueAddressSetDebug(msg.sender, "Add Element", "Reached, line 36");
	        _addElement(addx);
	}
    }
    
    function getElement(uint16 elementIndex) returns (address)
    {
    	UniqueAddressSetDebug(msg.sender, "getElement", "Reached");
	if (elementIndex >= size) 
	{
	    SetOutOfRange(msg.sender, "Set Out of range", elementIndex);
	    return 0;
	}
	else return addxs[elementIndex];
    }

    event Empty(address sender, string debug, string message);
    function empty()
    {
	Empty(msg.sender, "Method Empty", "Reached");
    }

    function getSize() returns (uint)
    {
    	UniqueAddressSetDebug(msg.sender, "getSize", "Reached");
	return size;
    }

}