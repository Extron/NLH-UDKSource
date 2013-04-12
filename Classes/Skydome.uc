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
	local vector windSpeeds;
	local vector windAngles;
	local float speed, angle;
	
	super.Tick(dt);
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		Material.SetScalarParameterValue('TimeOfDay', ArenaGRI(WorldInfo.GRI).WeatherMgr.TimeOfDay);
		Material.SetScalarParameterValue('CloudCoverage', ArenaGRI(WorldInfo.GRI).WeatherMgr.CloudCoverage);
		Material.SetScalarParameterValue('CloudSharpness', ArenaGRI(WorldInfo.GRI).WeatherMgr.CloudSharpness);
		
		speed = VSize(ArenaGRI(WorldInfo.GRI).WeatherMgr.SkyWind);
		
		windSpeeds.x = speed * 0.001 + 0.017;
		windSpeeds.y = speed * 0.001 + 0.005;
		windSpeeds.x = speed * 0.001 + 0.02;
		
		angle = Atan2(ArenaGRI(WorldInfo.GRI).WeatherMgr.SkyWind.y, ArenaGRI(WorldInfo.GRI).WeatherMgr.SkyWind.x);
			
		windAngles.x = angle + 0.2;
		windAngles.y = angle;
		windAngles.z = angle - 0.1;
		
		Material.SetScalarParameterValue('WindSpeedX', windSpeeds.x);
		Material.SetScalarParameterValue('WindSpeedY', windSpeeds.y);
		Material.SetScalarParameterValue('WindSpeedZ', windSpeeds.z);
		
		Material.SetScalarParameterValue('WindAngleX', windAngles.x);
		Material.SetScalarParameterValue('WindAngleY', windAngles.y);
		Material.SetScalarParameterValue('WindAngleZ', windAngles.z);
	}
}