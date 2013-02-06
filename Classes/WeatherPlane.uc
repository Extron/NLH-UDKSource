/*******************************************************************************
	WeatherPlane

	Creation date: 06/02/2013 12:06
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/


/**
 * The weather plane used for drawing weather effects like rain and snow.
 */
class WeatherPlane extends DynamicSMActor;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=SMesh
		StaticMesh=StaticMesh'ArenaWeather.Meshes.WeatherPlaneMesh'
		LightEnvironment=MyLightEnvironment
		Scale3D=(X=100,Y=100,Z=100)
	End Object
	StaticMeshComponent=SMesh
}