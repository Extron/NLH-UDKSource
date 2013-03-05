/*******************************************************************************
	SeqAct_SetNaturalWeather

	Creation date: 28/02/2013 13:25
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_SetNaturalWeather extends SequenceAction;

var bool NaturalWeather;

defaultproperties
{
	ObjName="Set Natural Weather"
	HandlerName="SetNaturalWeather"
	NaturalWeather=false
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Natural Weather", bWriteable=true, PropertyName=NaturalWeather)
}