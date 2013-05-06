/*******************************************************************************
	SnowMound

	Creation date: 21/02/2013 13:26
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SnowMound extends DynamicSMActor;

/**
 * A list of possible meshes that this snow mound can have.
 */
var array<StaticMesh> Meshes;

/**
 * Stores the current snow level of the mound.
 */
var float SnowLevel;

var float RandScaleComp;

var float RandScaleZComp;

var float RandLocComp;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	SetMesh();
}

simulated function Tick(float dt)
{
	local vector l;
	local vector s;
	
	super.Tick(dt);
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
			SnowLevel += dt * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
		else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Thawing)
			SnowLevel -= dt * ArenaGRI(WorldInfo.GRI).WeatherMgr.Temperature * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
		else
			SnowLevel = 0.0;
		
		SnowLevel = FClamp(SnowLevel, 0.0, 1.0);
		
		s.x = RandScaleComp * 10;
		s.y = RandScaleComp * 10;
		s.z = (SnowLevel ** 4) * RandScaleComp * RandScaleZComp * 2.5;
		
		StaticMeshComponent.SetScale3D(s);
		
		l.z = ((1 - (SnowLevel ** 4)) * -RandScaleComp) * 5 - 4 * RandScaleComp * RandLocComp;
		l.z = FMin(l.z, 0.0);
		
		StaticMeshComponent.SetTranslation(l);
	}
}

function SetMesh()
{
	local int i;
	
	i = Rand(Meshes.Length);
	
	StaticMeshComponent.SetStaticMesh(Meshes[i], true);	
	StaticMeshComponent.SetScale3D(vect(0, 0, 0));
	
	RandScaleComp = FRand() * 0.5 + 0.5;
	RandScaleZComp = FRand() * 0.5 + 0.5;;
	RandLocComp = FRand();
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ArenaWeather.Meshes.SnowMound1Mesh'
	End Object
	
	/*
	Meshes[0]=StaticMesh'ArenaWeather.Meshes.SnowMound1Mesh'
	Meshes[1]=StaticMesh'ArenaWeather.Meshes.SnowMound2Mesh'
	Meshes[2]=StaticMesh'ArenaWeather.Meshes.SnowMound3Mesh'
	Meshes[3]=StaticMesh'ArenaWeather.Meshes.SnowMound4Mesh'
	Meshes[4]=StaticMesh'ArenaWeather.Meshes.SnowMound5Mesh'
	Meshes[5]=StaticMesh'ArenaWeather.Meshes.SnowMound6Mesh'
	Meshes[6]=StaticMesh'ArenaWeather.Meshes.SnowMound7Mesh'
	Meshes[7]=StaticMesh'ArenaWeather.Meshes.SnowMound8Mesh'*/

	Meshes[0]=StaticMesh'ArenaWeather.Meshes.SnowMound2Mesh'
	Meshes[1]=StaticMesh'ArenaWeather.Meshes.SnowMound5Mesh'
	Meshes[2]=StaticMesh'ArenaWeather.Meshes.SnowMound6Mesh'
	Meshes[3]=StaticMesh'ArenaWeather.Meshes.SnowMound7Mesh'
}