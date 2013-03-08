/*******************************************************************************
	SeqAct_SetTimeOfDay

	Creation date: 28/02/2013 12:05
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_SetTimeOfDay extends SequenceAction;

var() float TimeOfDay;


defaultproperties
{
	ObjName="Set Time of Day"

	HandlerName="SetTimeOfDay"
	
	TimeOfDay=0.0

	VariableLinks(1)=(ExpectedType=class'SeqVar_Float', LinkDesc="Time of Day", bWriteable=true, PropertyName=TimeOfDay)
}