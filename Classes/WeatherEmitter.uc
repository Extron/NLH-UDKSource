/*******************************************************************************
	WeatherEmitter

	Creation date: 19/05/2013 05:43
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This class manages the weather emitters.
 */
class WeatherEmitter extends Actor;

/** 
 * The particle template to use when this effect is active. 
 */
var ParticleSystem SnowflakesTemplate;

/**
 * The particle system of the activated effect. 
 */
var ParticleSystemComponent Snowflakes;

/** 
 * The particle template to use when this effect is active. 
 */
var ParticleSystem RainSplashTemplate;

/** 
 * The particle system of the activated effect. 
 */
var ParticleSystemComponent RainSplash;

/**
 * The range at which rain particles begin to spawn.
 */
var float EmitterRangeRain;

/**
 * The range at which snow particles begin to spawn.
 */
var float EmitterRangeSnow;

simulated function Tick(float dt)
{
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
		{
			if (IsPlayerNear(EmitterRangeSnow))
			{
				if (Snowflakes == None)
					EmitSnow();
				else
					Snowflakes.ActivateSystem();
					
			}
			else if (Snowflakes != None)
			{
				Snowflakes.DeactivateSystem();
				Snowflakes = None;
			}
			
			if (RainSplash != None)
			{
				if (RainSplash.bIsActive)
					RainSplash.DeactivateSystem();
			}
				
			if (Snowflakes != None)
			{
				Snowflakes.SetFloatParameter('WeatherIntensity', ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity);
				//Snowflakes.SetVectorParameter('Wind', ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);
			}
		}
		else
		{
			if (Snowflakes != None)
			{
				if (Snowflakes.bIsActive)
					Snowflakes.DeactivateSystem();
			}
				
			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
			{
				if (IsPlayerNear(EmitterRangeRain))
				{
					if (RainSplash == None)
						EmitRainSplash();
					else
						RainSplash.ActivateSystem();
						
				}
				else if (RainSplash != None)
				{
					RainSplash.DeactivateSystem();
					RainSplash = None;
				}
			}
			else
		}
	}
}

function EmitSnow()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && SnowflakesTemplate != None)
	{		
		Snowflakes = WorldInfo.MyEmitterPool.SpawnEmitter(SnowflakesTemplate, Location);
		Snowflakes.SetAbsolute(false, false, false);
		Snowflakes.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Snowflakes.bUpdateComponentInTick = true;
	}
}

function EmitRainSplash()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && RainSplashTemplate != None)
	{		
		RainSplash = WorldInfo.MyEmitterPool.SpawnEmitter(RainSplashTemplate, Location);
		RainSplash.SetAbsolute(false, false, false);
		RainSplash.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		RainSplash.bUpdateComponentInTick = true;
	}
}

function bool IsPlayerNear(float range)
{
	local ArenaPlayerController iter;
	
	foreach LocalPlayerControllers(class'Arena.ArenaPlayerController', iter)
	{
		if (iter.Pawn != None && VSize(iter.Pawn.Location - Location) < range)
			return true;
	}
	
	return false;
}

defaultproperties
{
	EmitterRangeRain=768
	EmitterRangeSnow=2048
	SnowflakesTemplate=ParticleSystem'ArenaWeather.Particles.SnowParticles'
	RainSplashTemplate=ParticleSystem'ArenaWeather.Particles.RainParticles'
}