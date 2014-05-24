/*******************************************************************************
	LandscapeManager

	Creation date: 14/02/2013 16:09
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class LandscapeManager extends Actor;

/**
 * The level's landscape.
 */
var Landscape Landscape;

/**
 *
 */
var float SnowLevel;

/**
 * The level of water caused by rain on the landscape.
 */
var float RainLevel;

/**
 * Indicates that the object should be frozen.
 */
var bool Frozen;


function Initialize(Landscape lscp)
{
	Landscape = lscp;
}
	
function Destroyed()
{
	Landscape = None;
}

/**
 * Updates the landscape's material based on the current weather state.
 */
function Update(WeatherManager weather, float delta)
{
	local int i;

	//`log("Updating landscape");
	
	if (weather.Snowing)
	{;
		
		SnowLevel += delta * weather.WeatherIntensity * weather.SnowBuildupRate;
		RainLevel = 0;
		//`log("Adding snow to landscape" @ SnowLevel);
	}
	else if (weather.Thawing)
	{
		SnowLevel -= delta * weather.Temperature * weather.SnowBuildupRate;
	}
		
	if (weather.Raining)
	{
		//`log("Its raining");
		
		RainLevel += delta * weather.WeatherIntensity * weather.RainBuildupRate;
		SnowLevel = 0;
	}
	else
		RainLevel -= delta * weather.Temperature * weather.RainBuildupRate;
	
	SnowLevel = FClamp(SnowLevel, 0.0, 1.0);
	RainLevel = FClamp(RainLevel, 0.0, 1.0);
	
	if (Landscape != None)
	{			
		for (i = 0; i < Landscape.LandscapeComponents.Length; i++)
		{
			Landscape.LandscapeComponents[i].MaterialInstance.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			Landscape.LandscapeComponents[i].MaterialInstance.SetScalarParameterValue('Snow', SnowLevel > 0 ? 1 : 0);
			Landscape.LandscapeComponents[i].MaterialInstance.SetScalarParameterValue('Rain', (RainLevel > 0 && !Frozen) ? 1 : 0);
		}
	}
}