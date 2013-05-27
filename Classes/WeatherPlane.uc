/*******************************************************************************
	WeatherPlane

	Creation date: 06/02/2013 12:06
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/


/**
 * The weather plane used for drawing weather effects like rain and snow.
 */
class WeatherPlane extends StaticMeshActor;

/** The particle template to use when this effect is active. */
var ParticleSystem SnowflakesTemplate;

/** The particle system of the activated effect. */
var ParticleSystemComponent Snowflakes;

/** The particle template to use when this effect is active. */
var ParticleSystem RainSplashTemplate;

/** The particle system of the activated effect. */
var ParticleSystemComponent RainSplash;

/** A reference to the material that the actor uses. */
var MaterialInstanceConstant Material;

var float EmitterRange;

simulated function Tick(float dt)
{	
	local rotator r;
	
	if (Material == None)
	{
		Material = new class'MaterialInstanceConstant';
		Material.SetParent(StaticMeshComponent.GetMaterial(0));
		StaticMeshComponent.SetMaterial(0, Material);
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
		{
			Material.SetScalarParameterValue('WeatherIntensity', 0);
		
			if (IsPlayerNear())
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
				if (IsPlayerNear())
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
			
				Material.SetScalarParameterValue('WeatherIntensity', ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity);
				
				r = rotator(ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);

				r.Pitch = 1000 * VSize(ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);
				
				StaticMeshComponent.SetRotation(r);
			}
			else
				Material.SetScalarParameterValue('WeatherIntensity', 0);
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
		Snowflakes.SetActorParameter('WeatherPlane', self);
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
		RainSplash.SetActorParameter('WeatherPlane', self);
	}
}

function bool IsPlayerNear()
{
	local ArenaPlayerController iter;
	
	foreach LocalPlayerControllers(class'Arena.ArenaPlayerController', iter)
	{
		if (iter.Pawn != None && VSize(iter.Pawn.Location - Location) < EmitterRange)
			return true;
	}
	
	return false;
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
        StaticMesh = StaticMesh'ArenaWeather.Meshes.WeatherCylinderMesh'
		Scale3D=(X=1,Y=1,Z=1)
		bCastDynamicShadow=false
		CastShadow=false
		MaxDrawDistance=64
    End Object
	
	EmitterRange=2500
	bStatic=false
	bCollideActors=false
	bBlockActors=false
	SnowflakesTemplate=ParticleSystem'ArenaWeather.Particles.SnowParticles'
	RainSplashTemplate=ParticleSystem'ArenaWeather.Particles.RainDropSplashes'
}