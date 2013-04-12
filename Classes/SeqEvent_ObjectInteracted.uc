/*******************************************************************************
	SeqEvent_ObjectInteracted

	Creation date: 18/03/2013 15:20
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqEvent_ObjectInteracted extends SequenceEvent;

event Activated() 
{
	`log("Activating event" @ self);
}


defaultproperties
{
	ObjName="Object Interacted With"
	ObjCategory="Interactive"
	
	OutputLinks[0]=(LinkDesc="Activated")
}