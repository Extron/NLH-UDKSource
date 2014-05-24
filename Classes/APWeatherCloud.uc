/*******************************************************************************
	APWeatherCloud

	Creation date: 08/04/2014 08:37
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This component attaches to player pawns and spawns appropriate particles for weather effects.
 */
class APWeatherCloud extends Actor;


/**
 * The snow particle system to use.
 */
var ParticleSystem SnowParticleTemplate;

/**
 * The rain particle system to use.
 */
var ParticleSystem RainParticleTemplate;

/**
 * The snow particle system components.
 */
var array<ParticleSystemComponent> Snow;

/**
 * The rain particle system components.
 */
var array<ParticleSystemComponent> Rain;

/**
 * The radius at which to spawn particles.
 */
var float Radius;

/**
 * The height above the player to spawn particles.
 */
var float Height;

simulated function PostBeginPlay()
{
	local int i;
	
	super.PostBeginPlay();
	
	Snow.AddItem(GetNewComponent(SnowParticleTemplate));
	Rain.AddItem(GetNewComponent(RainParticleTemplate));
	
	for (i = 0; i < Snow.Length; i++)
		AttachComponent(Snow[i]);
		
	for (i = 0; i < Rain.Length; i++)
		AttachComponent(Rain[i]);
}

function ParticleSystemComponent GetNewComponent(ParticleSystem template)
{
	local ParticleSystemComponent component;
	component = new(self) class'ParticleSystemComponent';
	component.bAutoActivate = false;
	component.SetTemplate(template);
	component.SetAbsolute(false, false, false);
	component.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
	component.bUpdateComponentInTick = true;
	component.SetTranslation(vect(0, 0, 1) * Height);
	
	return component;
}

simulated function Tick(float dt)
{
	local int i;
	local float scale;
	
	if (Owner != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
			scale = 1.25;
		else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
			scale = 0.5;
			
		SetLocation(Owner.Location + scale * Owner.Velocity);
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
		{
			for (i = 0; i < Snow.Length; i++)
			{
				if (!Snow[i].bIsActive)
					Snow[i].ActivateSystem();
					
				Snow[i].SetFloatParameter('WeatherIntensity', ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity);
				//Snow[i].SetVectorParameter('Wind', ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);
			}
		}
		else
		{
			for (i = 0; i < Snow.Length; i++)
			{
				if (Snow[i].bIsActive)
					Snow[i].DeactivateSystem();
			}

			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
			{
				for (i = 0; i < Rain.Length; i++)
				{
					if (!Rain[i].bIsActive)
						Rain[i].ActivateSystem();
						
					Rain[i].SetFloatParameter('WeatherIntensity', ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity);
					//Rain[i].SetVectorParameter('Wind', ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);
				}
			}
			else
			{
				for (i = 0; i < Snow.Length; i++)
				{
					if (Rain[i].bIsActive)
						Rain[i].DeactivateSystem();
				}
			}
		}
	}
}

defaultproperties
{
	Height=256
	SnowParticleTemplate=ParticleSystem'ArenaWeather.Particles.SnowParticles'
	RainParticleTemplate=ParticleSystem'ArenaWeather.Particles.RainParticles'
}