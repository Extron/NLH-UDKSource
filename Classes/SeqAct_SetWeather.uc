/*******************************************************************************
	SeqAct_SetWeather

	Creation date: 28/02/2013 11:48
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_SetWeather extends SequenceAction;

/**
 * The wind input for the sequence action.
 */
var() vector Wind;

/**
 * The cloud coverage input for the sequence action.
 */
var() float CloudCoverage;

/**
 * The temperature input for the sequence action.
 */
var() float Temperature;

/**
 * The weather intensity input for the sequence action.
 */
var() float WeatherIntensity;


defaultproperties
{
	ObjName="Set Weather Variables"

	// This is the name of the event that will be triggered when this action is called //
	HandlerName="SetWeather"

   Wind=(X=0,Y=0)
   CloudCoverage=1.0
   Temperature=0.8
   WeatherIntensity=0.0
   
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector', LinkDesc="Wind", bWriteable=true, PropertyName=Wind)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float', LinkDesc="Cloud Coverage", bWriteable=true, PropertyName=CloudCoverage)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Float', LinkDesc="Temperature", bWriteable=true, PropertyName=Temperature)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Float', LinkDesc="Weather Intensity", bWriteable=true, PropertyName=WeatherIntensity)
}