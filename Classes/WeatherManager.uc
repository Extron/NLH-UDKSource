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
class WeatherManager extends Actor
	placeable;

/**
 * The size of the noise array.
 */
const ArraySize = 100;


/**
 * The basic white noise used to generate a unique Perlin noise function each time.
 */
var array<float> WhiteNoise;

/**
 * The weather volumes on the map.
 */
var array<WeatherVolume> Volumes;

/**
 * The template to use for instant hits for the ability.
 */
var ParticleSystem LightningBoltTemplate;

/**
 * The template for rain splashes.
 */
var ParticleSystem RainSplashTemplate;

/**
 * The light used for the lightning.
 */
var LightningLight Light;

/**
 * The level's landscape.
 */
var LandscapeManager Landscape;

/**
 * The ambient sound to play during a thunderstorm.
 */
var SoundCue ThunderstormSound;

/**
 * The wind vector;
 */
var interp vector Wind;

/**
 * The wind in the sky.
 */
var interp vector SkyWind;

/**
 * The time of day.
 */
var interp float TimeOfDay;

/**
 * The weather counter for advancing weather.
 */
var float WeatherCounter;

/**
 * How fast a day progresses in the map.
 */
var interp float DayRate;

/**
 * The rate at which weather changes.
 */
var interp float WeatherRate;

/**
 * The rate of decay of the weather from starting values to randomness.
 */
var float WeatherDecayRate;

/**
 * The tempurature.
 */
var interp float Temperature;

/**
 * The cloud coverage.
 */
var interp float CloudCoverage;

/** 
 * The sharpness of the clouds. 
 */
var interp float CloudSharpness;

/**
 * The intensity of the weather effects.
 */
var interp float WeatherIntensity;

/**
 * If natural weather progression is used, then the actual cloud coverage is computed as a decay from this value into a random value.
 */
var float StartCloudCoverage; 

/**
 * If natural weather progression is used, then the actual temperature is computed as a decay from this value into a random value.
 */
var float StartTemperature;

/**
 * If natural weather progression is used, then the actual weather intensity is computed as a decay from this value into a random value.
 */
var float StartWeatherIntensity;

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
 * The value that the temperature needs to be greater than to start thawing.
 */
var float FreezeTempThreshold;

/**
 * The value that the temperature needs to be greater than to start raining.
 */
var float RainTempThresholdMin;

/**
 * The value that the temperature needs to be lower than to start raining.
 */
var float RainTempThresholdMax;

/**
 * The value that the cloud coverage needs to be near to start a thunder storm.
 */
var float LightningCloudThreshold;

/**
 * The value that the weather intensity needs to be above when it is raining to start a thunder storm.
 */
var float LightningIntensityThreshold;

/** 
 * The rate of snow buildup on the environment.
 */
var float SnowBuildupRate;

/** 
 * The rate of rain water buildup on the environment.
 */
var float RainBuildupRate;

/**
 * The minimum amount of time between lightning strikes.
 */
var float LightningRateMin;

/**
 * The maximum amount of time between lightning strikes.
 */
var float LightningRateMax;

/**
 * The minimum distance that lighting can be from the origin.
 */
var float LightningRangeMin;

/**
 * The maximum distance that lightning can be from the origin.
 */
var float LightningRangeMax;

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
 * Indicates that it is cold enough enough for water to freeze.
 */
var bool Freezing;

/**
 * Indicates that it is raining.
 */
var bool Raining;

/**
 * Indicates that it is thunder storming.
 */
var bool ThunderStorm;


simulated function PostBeginPlay()
{
	local int i;
	local WeatherVolume volume;
	local Landscape iter;

	for (i = 0; i < ArraySize; i++)
	{
		WhiteNoise[i] = FRand();
	}
	
	StartCloudCoverage = FRand();
	StartWeatherIntensity = FRand();
	StartTemperature = FRand();
	
	CloudCoverage = StartCloudCoverage;
	WeatherIntensity = StartWeatherIntensity;
	Temperature = StartTemperature;
	
	foreach AllActors(class'WeatherVolume', volume)
	{
		Volumes.AddItem(volume);
		volume.SpawnWeather(self);
	}
	
	Landscape = Spawn(class'Arena.LandscapeManager', self);
	
	foreach AllActors(class'Landscape', iter)
	{
		Landscape.Initialize(iter);
		break;
	}
}

function SetWeather(SeqAct_SetWeather action)
{
	`log("Setting weather through seqact.");
	
	Wind = action.Wind;
	StartCloudCoverage = action.CloudCoverage;
	StartTemperature = action.Temperature;
	StartWeatherIntensity = action.WeatherIntensity;
}

function SetTimeOfDay(SeqAct_SetTimeOfDay action)
{
	TimeOfDay = action.TimeOfDay;
}

function SetNaturalWeather(SeqAct_SetNaturalWeather action)
{
	TickWeather = action.NaturalWeather;
}

function SetProgressDay(SeqAct_SetProgressDay action)
{
	TickDay = action.ProgressDay;
}

simulated function Tick(float dt)
{
	local array<SequenceObject> events;
	local float time;
	local float rand;
	local float windSpeed;
	local float windAngle;
	
	if (TickDay)
		TimeOfDay += dt * DayRate;
		
	if (TimeOfDay > Pi)
		TimeOfDay = 0;
	
	if (TickWeather)
	{
		WeatherCounter += dt * WeatherRate;
		
		rand = (GetNoise(WeatherCounter, 0, 0.25) + GetNoise(WeatherCounter, 1, 0.25) + GetNoise(WeatherCounter, 2, 0.25) + GetNoise(WeatherCounter, 3, 0.25) - 0.5) * 1.5;
		Temperature = ExpDecay(StartTemperature, rand, WeatherCounter, WeatherDecayRate);
		
		rand = (GetNoise(WeatherCounter * 0.5, 0, 0.5) + GetNoise(WeatherCounter * 0.5, 1, 0.5) + GetNoise(WeatherCounter * 0.5, 2, 0.5) + GetNoise(WeatherCounter * 0.5, 3, 0.5) - 0.5) * 1.5;
		CloudCoverage = ExpDecay(StartCloudCoverage, rand, WeatherCounter, WeatherDecayRate);

		windSpeed = GetNoise(WeatherCounter * 0.673, 0, 0.15) + GetNoise(WeatherCounter * 0.673, 1, 0.15) + GetNoise(WeatherCounter * 0.673, 2, 0.15) + GetNoise(WeatherCounter * 0.673, 3, 0.15);
		windSpeed = (windSpeed - 0.5) * 1.5;
		windSpeed *= 5.0;
		
		windAngle = GetNoise(WeatherCounter * 0.0654, 0, 0.3) + GetNoise(WeatherCounter * 0.0654, 1, 0.3) + GetNoise(WeatherCounter * 0.0654, 2, 0.3) + GetNoise(WeatherCounter * 0.0654, 3, 0.3);
		windAngle = (windAngle - 0.5) * 1.5;
		windAngle *= 2 * Pi;
		
		Wind.x = cos(windAngle) * windSpeed;
		Wind.y = sin(windAngle) * windSpeed;
		
		windSpeed = GetNoise(WeatherCounter * 0.173, 0, 0.15) + GetNoise(WeatherCounter * 0.173, 1, 0.15) + GetNoise(WeatherCounter * 0.173, 2, 0.15) + GetNoise(WeatherCounter * 0.173, 3, 0.15);
		windSpeed = (windSpeed - 0.5) * 1.5;
		windSpeed *= 5.0;
		
		windAngle = GetNoise(WeatherCounter * 0.0154, 0, 0.3) + GetNoise(WeatherCounter * 0.0154, 1, 0.3) + GetNoise(WeatherCounter * 0.0154, 2, 0.3) + GetNoise(WeatherCounter * 0.0154, 3, 0.3);
		windAngle = (windAngle - 0.5) * 1.5;
		windAngle *= 2 * Pi;
		
		SkyWind.x = cos(windAngle) * windSpeed;
		SkyWind.y = sin(windAngle) * windSpeed;
	}
	
	if (CloudCoverage < WeatherCloudThreshold)
	{
		if (Temperature < SnowTempThreshold)
		{
			Snowing = true;
		}
		else if (Temperature > RainTempThresholdMin && Temperature < RainTempThresholdMax)
		{
			Raining = true;
			
			if (CloudCoverage <= LightningCloudThreshold && WeatherIntensity >= LightningIntensityThreshold)
			{
				
				if (!ThunderStorm)
				{
					time = FRand() * (LightningRateMax - LightningRateMin) + LightningRateMin;
					SetTimer(time, false, 'LightningStrike');
				}
				
				ThunderStorm = true;
			}
			else
			{
				ThunderStorm = false;
				ClearTimer('LightningStrike');
			}
		}
		else
		{
			Snowing = false;
			Raining = false;
		}
	}
	else
	{
		Snowing = false;
		Raining = false;
		WeatherIntensity = 0.0;
	}
	
	if (Temperature > ThawTempThreshold)
		Thawing = true;
	else if (Temperature < FreezeTempThreshold)
		Freezing = true;
		
	if (Snowing)
	{
		if (TickWeather)
		{
			rand = FClamp((GetNoise(WeatherCounter, 0, 0.25) + GetNoise(WeatherCounter, 1, 0.25) + GetNoise(WeatherCounter, 2, 0.25) + GetNoise(WeatherCounter, 3, 0.25) - 0.5) * 1.5, 0.0, 1.0);
			WeatherIntensity = ExpDecay(StartWeatherIntensity, rand, WeatherCounter, WeatherDecayRate);
		}
	}
	else if (Raining)
	{
		if (TickWeather)
		{
			rand = FClamp((GetNoise(WeatherCounter, 0, 0.25) + GetNoise(WeatherCounter, 1, 0.25) + GetNoise(WeatherCounter, 2, 0.25) + GetNoise(WeatherCounter, 3, 0.25) - 0.5) * 1.5, 0.0, 1.0);
			WeatherIntensity = ExpDecay(StartWeatherIntensity, rand, WeatherCounter, WeatherDecayRate);
		}
	}
	
	if (TickWeather)
	{
		WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'Arena.SeqEvent_WeatherUpdated', true, events);		
		ActivateEventClass(class'Arena.SeqEvent_WeatherUpdated', self, events);
	}
	
	Landscape.Update(self, dt);
}

function Destroyed()
{
	Landscape.Destroy();
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

function float ExpDecay(float initial, float random, float time, float rate)
{
	return Lerp(initial, random, 1 - Exp(-rate * time));
}

function LightningStrike()
{
	local ParticleSystemComponent lightning;
	local vector l;
	local float time;
	
	if (LightningBoltTemplate != None)
	{		
		l.x = (FRand() * (LightningRangeMax - LightningRangeMin) + LightningRangeMin) * (FRand() > 0.5 ? -1 : 1);
		l.y = (FRand() * (LightningRangeMax - LightningRangeMin) + LightningRangeMin) * (FRand() > 0.5 ? -1 : 1);
		l.z = 2500;
		
		lightning = WorldInfo.MyEmitterPool.SpawnEmitter(LightningBoltTemplate, l);
		lightning.SetAbsolute(false, false, false);
		lightning.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		lightning.bUpdateComponentInTick = true;
		
		time = FRand() * (LightningRateMax - LightningRateMin) + LightningRateMin;
		
		if (Light == None)
		{
			Light = Spawn(class'Arena.LightningLight', self, , l);
			SetTimer(0.5, false, 'DisableLight');
		}
		
		Spawn(class'Arena.SA_LightningStrike', self, , l);
		
		if (ThunderStorm)
			SetTimer(time, false, 'LightningStrike');
	}
}

function DisableLight()
{
	if (Light != None)
	{
		Light.Destroy();
		Light = None;
	}
}

defaultproperties
{
	LightningBoltTemplate=ParticleSystem'ArenaParticles.Particles.Lightning'
	
	ThunderstormSound=SoundCue'ArenaWeather.Audio.ThunderstormLoop'
	
	TimeOfDay=0
	DayRate=0.01
	WeatherRate=0.05
	WeatherDecayRate=0.05
	CloudCoverage=0
	WeatherIntensity=0
	CloudSharpness=0.001
	
	TickDay=true
	TickWeather=true
	
	WeatherCloudThreshold=0.25
	SnowTempThreshold=0.5
	ThawTempThreshold=0.65
	FreezeTempThreshold=0.32
	RainTempThresholdMin=0.66
	RainTempThresholdMax=0.75
	LightningCloudThreshold=0.1
	LightningIntensityThreshold=0.95
	SnowBuildupRate=0.05
	RainBuildupRate=0.05
	LightningRateMax=15
	LightningRateMin=5
	LightningRangeMax=15000
	LightningRangeMin=5000
}