/*******************************************************************************
	SeqAct_SetProgressDay

	Creation date: 28/02/2013 16:09
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_SetProgressDay extends SequenceAction;

var() bool ProgressDay;

defaultproperties
{
	ObjName="Set Progress Day"
	HandlerName="SetProgressDay"
	ProgressDay=false
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Progress Day", bWriteable=true, PropertyName=ProgressDay)
}