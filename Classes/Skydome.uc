/*******************************************************************************
	Skydome

	Creation date: 24/12/2012 01:14
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Skydome extends DynamicSMActor;

/** A reference to the material that the skydome uses. */
var MaterialInstanceConstant Material;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Material = new class'MaterialInstanceConstant';
	Material.SetParent(StaticMeshComponent.GetMaterial(0));
	StaticMeshComponent.SetMaterial(0, Material);
}

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	if (ArenaGRI(WorldInfo.GRI) != None)
	{
		Material.SetScalarParameterValue('TimeOfDay', ArenaGRI(WorldInfo.GRI).WeatherMgr.TimeOfDay);
		Material.SetScalarParameterValue('CloudCoverage', ArenaGRI(WorldInfo.GRI).WeatherMgr.CloudCoverage);
		Material.SetScalarParameterValue('CloudSharpness', ArenaGRI(WorldInfo.GRI).WeatherMgr.CloudSharpness);
	}
}