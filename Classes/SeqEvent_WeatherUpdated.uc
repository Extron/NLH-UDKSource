/*******************************************************************************
	SeqEvent_WeatherUpdated

	Creation date: 15/09/2013 20:30
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqEvent_WeatherUpdated extends SequenceEvent;

event Activated() 
{
	`log("Activating event" @ self);
}

defaultproperties
{
	ObjName="Weather Updated"
	ObjCategory="Weather"
	bPlayerOnly=false
	MaxTriggerCount=0
}