/*******************************************************************************
	WeatherVolume

	Creation date: 12/03/2013 13:21
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A weather volume dictates where wheather effects like snow and rain can spawn.
 */
class WeatherVolume extends PhysicsVolume
	placeable;

var Array<WeatherPlane> Planes;

var Array<SnowMound> SnowMounds;

/**
 * The density of the weather planes for this volume.  Note that this should not be set too high, or 
 * the game will suffer poor performance.
 */
var() float WeatherPlaneDensity;

/**
 * The density of the snow mounds for this volume.
 */
var() float SnowMoundDensity;

/**
 * Indicates that snow mounds can be spawned in this area.
 */
var() bool SpawnSnowMounds;

var WeatherManager Parent;

simulated function SpawnWeather(WeatherManager manager)
{
	local WeatherPlane p;
	local SnowMound s;
	local vector bounds;
	local vector pos, traceLoc, traceNorm;
	local rotator rotn;
	local float area, x, y;
	local int planeCount;
	local int moundCount;
	local int i;
	
	Parent = manager;
	
	bounds = BrushComponent.Bounds.BoxExtent * 2;
	
	area = bounds.x * bounds.y;
	
	planeCount = area * 0.00005 * WeatherPlaneDensity;
	moundCount = area * 0.00005 * SnowMoundDensity;
	
	`log("Planes" @ planeCount @ "Mounds" @ moundCount @ "Area" @ area);
	
	for (i = 0; i < planeCount; i++)
	{
		x = FRand() * bounds.x * 0.5 * (FRand() > 0.5 ? 1 : -1) + Location.X;
		y = FRand() * bounds.y * 0.5 * (FRand() > 0.5 ? 1 : -1) + Location.Y;
		
		pos.x = x;
		pos.y = y;
		
		p = Spawn(class'Arena.WeatherPlane', manager, , pos);
		Planes.AddItem(p);
	}
	
	if (SpawnSnowMounds)
	{
		for (i = 0; i < moundCount; i++)
		{
			x = FRand() * bounds.x * 0.5 * (FRand() > 0.5 ? 1 : -1) + Location.X;
			y = FRand() * bounds.y * 0.5 * (FRand() > 0.5 ? 1 : -1) + Location.Y;

			pos.x = x;
			pos.y = y;
			pos.z = bounds.z * 0.5 + Location.z;
			
			rotn.Yaw = Rand(65536);
			
			if (Trace(traceLoc, traceNorm, pos * vect(1, 1, 0) - vect(0, 0, 100), pos) != None)
			{
				s = Spawn(class'Arena.SnowMound', manager, , traceLoc, rotn);
				SnowMounds.AddItem(s);
			}
		}
	}
}


event PawnEnteredVolume(Pawn Other)
{
	`log("Pawn entered volume" @ Other);
	
	if (ArenaPawn(Other) != None)
		ArenaPawn(Other).EnterWeatherVolume(Parent);
}

event PawnLeavingVolume(Pawn Other)
{
	`log("Pawn left volume" @ Other);
	
	if (ArenaPawn(Other) != None)
		ArenaPawn(Other).ExitWeatherVolume();
}

defaultproperties
{
	BrushColor=(R=0,G=0,B=255,A=255)
	
	//bCollideActors=false
}