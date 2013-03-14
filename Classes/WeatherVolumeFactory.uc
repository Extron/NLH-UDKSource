/*******************************************************************************
	WeatherVolumeFactory

	Creation date: 12/03/2013 13:40
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeatherVolumeFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Weather Volume"
	ActorClass=class'Arena.WeatherVolume'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}