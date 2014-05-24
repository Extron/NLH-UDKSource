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

/**
 * A list of emitters that make up the weather effects.
 */
var Array<WeatherEmitter> Emitters;

var Array<SnowMound> SnowMounds;

/**
 * The density of the weather planes for this volume.  Note that this should not be set too high, or 
 * the game will suffer poor performance.
 */
var() float WeatherEmitterDensity;

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
	local SnowMound s;
	local vector bounds;
	local vector pos, traceLoc, traceNorm;
	local rotator rotn;
	local float area, lambda;
	local int emitterCount, emitterCountX, emitterCountY;
	local int moundCount;
	local int i;
	
	Parent = manager;
	
	bounds = BrushComponent.Bounds.BoxExtent * 2;
	
	area = bounds.x * bounds.y;
	lambda = Sqrt(WeatherEmitterDensity);
	
	emitterCount = area * 0.00015 * WeatherEmitterDensity;
	emitterCountX = bounds.x * Sqrt(0.00015) * lambda;
	emitterCountY = bounds.y * Sqrt(0.00015) * lambda;
	moundCount = area * 0.00005 * SnowMoundDensity;
	
	for (i = 0; i < emitterCount; i++)
	{
		pos.x  = bounds.x * (i % emitterCountX) / emitterCountX + (Location.X - bounds.x * 0.5);
		pos.y = bounds.y * (i / emitterCountX) / emitterCountY + (Location.Y - bounds.y * 0.5);
		//pos.z = 128;
		//Emitters.AddItem(Spawn(class'Arena.WeatherEmitter', Parent, , pos));
	}
	
	if (SpawnSnowMounds)
	{
		for (i = 0; i < moundCount; i++)
		{
			pos.x = FRand() * bounds.x * 0.5 * (FRand() > 0.5 ? 1 : -1) + Location.X;
			pos.y = FRand() * bounds.y * 0.5 * (FRand() > 0.5 ? 1 : -1) + Location.Y;
			pos.z = bounds.z * 0.5 + Location.z;

			
			if (Landscape(Trace(traceLoc, traceNorm, pos * vect(1, 1, 0) - vect(0, 0, 100), pos)) != None)
			{
				rotn = rotator(traceNorm cross vect(1, 0, 0));
				rotn.Yaw = Rand(65536);
				
				s = Spawn(class'Arena.SnowMound', manager, , traceLoc, rotn);
				SnowMounds.AddItem(s);
			}
		}
	}
}

event PawnEnteredVolume(Pawn Other)
{
	if (ArenaPawn(Other) != None)
		ArenaPawn(Other).EnterWeatherVolume(Parent);
}

event PawnLeavingVolume(Pawn Other)
{
	if (ArenaPawn(Other) != None)
		ArenaPawn(Other).ExitWeatherVolume();
}

defaultproperties
{
	BrushColor=(R=0,G=0,B=255,A=255)
}