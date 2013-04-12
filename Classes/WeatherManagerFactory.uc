/*******************************************************************************
	WeatherManagerFactory

	Creation date: 28/02/2013 11:59
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeatherManagerFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Weather Manager"
	ActorClass=class'Arena.WeatherManager'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}