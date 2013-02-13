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

/** A reference to the material that the actor uses. */
var MaterialInstanceConstant Material;

simulated function Tick(float dt)
{
	if (Material == None)
	{
		Material = new class'MaterialInstanceConstant';
		Material.SetParent(StaticMeshComponent.GetMaterial(0));
		StaticMeshComponent.SetMaterial(0, Material);
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
		{
			Material.SetScalarParameterValue('WeatherIntensity', 0);
		
			if (Snowflakes == None)
				EmitSnow();
			
			if (Snowflakes != None)
			{
				if (!Snowflakes.bIsActive)
					Snowflakes.ActivateSystem();
				
				Snowflakes.SetFloatParameter('WeatherIntensity', ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity);
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
				Material.SetScalarParameterValue('WeatherIntensity', ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity);
			else
				Material.SetScalarParameterValue('WeatherIntensity', 0);
		}
	}
}

function EmitSnow()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && SnowflakesTemplate != None)
	{		
		Snowflakes = WorldInfo.MyEmitterPool.SpawnEmitter(SnowflakesTemplate, vect(0, 0, 0));
		Snowflakes.SetAbsolute(false, false, false);
		Snowflakes.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Snowflakes.bUpdateComponentInTick = true;
		Snowflakes.SetActorParameter('WeatherPlane', self);
	}
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
        StaticMesh = StaticMesh'ArenaWeather.Meshes.WeatherPlaneMesh'
		Scale=10
		bCastDynamicShadow=false
		CastShadow=false
    End Object
	
	bStatic=false
	bCollideActors=false
	bBlockActors=false
	SnowflakesTemplate=ParticleSystem'ArenaWeather.Particles.SnowParticles'
}