/*******************************************************************************
	SeqEvent_SwitchToggled

	Creation date: 28/04/2014 20:24
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class SeqEvent_SwitchToggled extends SequenceEvent;

defaultproperties
{
	ObjName="Switch Toggled"
	ObjCategory="Interactive"
	
	OutputLinks[0]=(LinkDesc="Off")
	OutputLinks[1]=(LinkDesc="On")
	
	VariableLinks(1)=(ExpectedType=class'SeqVar_Switch',LinkDesc="Switch",bWriteable=true)
}