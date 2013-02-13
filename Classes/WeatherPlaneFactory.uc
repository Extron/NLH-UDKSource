/*******************************************************************************
	WeatherPlaneFactory

	Creation date: 06/02/2013 12:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeatherPlaneFactory extends ActorFactoryStaticMesh;

defaultproperties
{
	MenuName="Add Weather Plane"
	NewActorClass=class'Arena.WeatherPlane'
}