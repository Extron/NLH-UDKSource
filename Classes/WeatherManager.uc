/*******************************************************************************
	WeatherManager

	Creation date: 05/02/2013 10:37
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This class manages a map's weather, using a noise function to alter
 * temperature, wind, and cloud coverage to simulate weather effects.
 */
class WeatherManager extends Actor;

/**
 * The size of the noise array.
 */
const ArraySize = 100;

/**
 * The amount of weather planes to add to the map.
 */
const WeatherPlaneCount = 35;

/**
 * The basic white noise used to generate a unique Perlin noise function each time.
 */
var array<float> WhiteNoise;

/**
 * A list of references to the weather planes on the level.
 */
var array<WeatherPlane> Planes;

/**
 * The wind vector;
 */
var vector Wind;

/**
 * The time of day.
 */
var float TimeOfDay;

/**
 * The weather counter for advancing weather.
 */
var float WeatherCounter;

/**
 * How fast a day progresses in the map.
 */
var float DayRate;

/**
 * The rate at which weather changes.
 */
var float WeatherRate;

/**
 * The tempurature.
 */
var float Temperature;

/**
 * The cloud coverage.
 */
var float CloudCoverage;

/** 
 * The sharpness of the clouds. 
 */
var float CloudSharpness;

/**
 * The intensity of the weather effects.
 */
var float WeatherIntensity;

/**
 * This stores the value that the cloud coverage needs to be lower than to start weather effects.
 */
var float WeatherCloudThreshold;

/**
 * The value that the temperature needs to be lower than to start snow.
 */
var float SnowTempThreshold;

/**
 * The value that the temperature needs to be greater than to start thawing.
 */
var float ThawTempThreshold;

/**
 * The value that the temperature needs to be greater than to start raining.
 */
var float RainTempThresholdMin;

/**
 * The value that the temperature needs to be lower than to start raining.
 */
var float RainTempThresholdMax;

/** 
 * The rate of snow buildup on the environment.
 */
var float SnowBuildupRate;

/** 
 * The rate of rain water buildup on the environment.
 */
var float RainBuildupRate;

/**
 * Indicates that we should advance the time of day.
 */
var bool TickDay;

/**
 * Indicates that we should advance the weather.
 */
var bool TickWeather;

/**
 * Indicates that it is snowing.
 */
var bool Snowing;

/**
 * Indicates that it is warm enough for snow and ice to melt.
 */
var bool Thawing;

/**
 * Indicates that it is raining.
 */
var bool Raining;


simulated function PostBeginPlay()
{
	local int i;
	local float x, y;
	local int th;
	local vector v;
	local rotator r;
	local WeatherPlane p;
	
	for (i = 0; i < ArraySize; i++)
	{
		WhiteNoise[i] = FRand();
	}

	//Spawn the weather planes to use.
	for (i = 0; i < WeatherPlaneCount; i++)
	{
		x = FRand() * 1000 * (FRand() > 0.5 ? 1 : -1);
		y = FRand() * 1000 * (FRand() > 0.5 ? 1 : -1);

		th = Rand(65536);
		
		v.x = x;
		v.y = y;
		r.Yaw = th;
		
		p = Spawn(class'Arena.WeatherPlane', Self, , v, r);
		Planes.AddItem(p);
	}
}

simulated function Tick(float dt)
{
	if (TickDay)
		TimeOfDay += dt * DayRate;
		
	if (TickWeather)
	{
		WeatherCounter += dt * WeatherRate;
		
		Temperature = GetNoise(WeatherCounter, 0, 0.25) + GetNoise(WeatherCounter, 1, 0.25) + GetNoise(WeatherCounter, 2, 0.25) + GetNoise(WeatherCounter, 3, 0.25);
		Temperature = (Temperature - 0.5) * 1.5;
		
		CloudCoverage = GetNoise(WeatherCounter * 1.5, 0, 0.5) + GetNoise(WeatherCounter * 1.5, 1, 0.5) + GetNoise(WeatherCounter * 1.5, 2, 0.5) + GetNoise(WeatherCounter * 1.5, 3, 0.5);
		CloudCoverage = (CloudCoverage - 0.5) * 1.5;

		CloudCoverage = 0.0;
		Temperature = 0.7;
		
		if (CloudCoverage < WeatherCloudThreshold)
		{
			if (Temperature < SnowTempThreshold)
			{
				Snowing = true;
				WeatherIntensity = 0.0;
			}
			else if (Temperature > RainTempThresholdMin && Temperature < RainTempThresholdMax)
			{
				Raining = true;
			}
			else
			{
				Snowing = false;
				Raining = false;
			}
		}
		
		if (Temperature > ThawTempThreshold)
		{
			Snowing = false;
			Thawing = true;
		}
		if (Snowing)
		{
			WeatherIntensity = GetNoise(WeatherCounter, 0, 0.25) + GetNoise(WeatherCounter, 1, 0.25) + GetNoise(WeatherCounter, 2, 0.25) + GetNoise(WeatherCounter, 3, 0.25);
			WeatherIntensity = FClamp((WeatherIntensity - 0.5) * 1.5, 0.0, 1.0);
		}
		else if (Raining)
		{
			WeatherIntensity = GetNoise(WeatherCounter, 0, 0.25) + GetNoise(WeatherCounter, 1, 0.25) + GetNoise(WeatherCounter, 2, 0.25) + GetNoise(WeatherCounter, 3, 0.25);
			WeatherIntensity = FClamp((WeatherIntensity - 0.5) * 1.5, 0.0, 1.0);
			//WeatherIntensity = 1;
		}
	}
}

function float GetNoise(float value, int octave, float persistance)
{
	local int frequency;
	local float amplitude;
	
	frequency = 2 ** octave;
	amplitude = persistance ** octave;
	
	return InterpolateNoise(value * frequency) * amplitude;
}

function float InterpolateNoise(float x)
{
	local int x0, x1;
	local float frac;
	
	x0 = x;
	x1 = x0 + 1;
	frac = x - x0;
	
	return Interpolate(SmoothNoise(x0), SmoothNoise(x1), frac);
}

function float SmoothNoise(int value)
{
	local int x0, x1, x2;
	
	x0 = value % ArraySize;
	x1 = (x0 + 1);
	x2 = (x0 - 1);
	
	if (x1 >= ArraySize)
		x1 = 0;
		
	if (x2 < 0)
		x2 = ArraySize - 1;
	
	return WhiteNoise[x0] / 2 + WhiteNoise[x1] / 4 + WhiteNoise[x2] / 4;
}

function float Interpolate(float f1, float f2, float a)
{
	local float x;
	x = (1 - Cos(a * 3.1415927)) * 0.5;
	return  f1 * (1 - x) + f2 * x;
}

defaultproperties
{
	TimeOfDay=1
	DayRate=0.1
	WeatherRate=0.5
	CloudCoverage=0
	CloudSharpness=0.001
	
	TickDay=true
	TickWeather=true
	
	WeatherCloudThreshold=0.5
	SnowTempThreshold=0.5
	ThawTempThreshold=0.65
	RainTempThresholdMin=0.66
	RainTempThresholdMax=0.75
	SnowBuildupRate=1.5
	RainBuildupRate=1.5
}