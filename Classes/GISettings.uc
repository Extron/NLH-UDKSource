/*******************************************************************************
	GISettings

	Creation date: 31/07/2013 19:36
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This class stores settings for game types that are loaded in on game start.  Provides a bridge between the UI and the game, allowing players
 * to make their own game settings.
 */
class GISettings extends Component;


/**
 * The game's time limit.  A negative number indicates an infinite time limit.
 */
var float TimeLimit;

/**
 * The amount of seconds for respawn.
 */
var float RespawnTime;

/**
 * Gets the time of day to start at.  A negative number indicates a random start time.
 */
var float StartTime;

/**
 * Gets the starting temperature on the map.  A negative number indicates a random temperature.
 */
var float StartTemperature;

/**
 * Gets the starting cloud coverage on the map.  A negative number indicates a random cloud coverage.
 */
var float StartCloudCoverage;

/**
 * Gets the starting weather intensity on the map.  A negative number indicates a random intensity.
 */
var float StartWeatherIntensity;

/**
 * Indicates that the weather progresses in the game.
 */
var bool WeatherProgression;

/**
 * Indicates that the day progresses in the game.
 */
var bool DayCycleProgression;

/**
 * The number of lives that the player has to start with.  A negative number indicates infinite lives.
 */
var int Lives;

function string Serialize()
{
	local string serialization;
	
	serialization = "";
	serialization $= string(TimeLimit) $ "!";
	serialization $= string(RespawnTime) $ "!";
	serialization $= string(StartTime) $ "!";
	serialization $= string(StartTemperature) $ "!";
	serialization $= string(StartCloudCoverage) $ "!";
	serialization $= string(WeatherProgression) $ "!";
	serialization $= string(DayCycleProgression) $ "!";
	serialization $= string(Lives);
	
	return serialization;
}

function Deserialize(string serialization)
{
	local array<string> substr;
	
	substr = SplitString(serialization, "!");

	if (substr.Length == 8)
	{
		TimeLimit = float(substr[0]);
		RespawnTime = float(substr[1]);
		StartTime = float(substr[2]);
		StartTemperature = float(substr[3]);
		StartCloudCoverage = float(substr[4]);
		WeatherProgression = bool(substr[5]);
		DayCycleProgression = bool(substr[6]);
		Lives = int(substr[7]);
	}
}

defaultproperties
{
	TimeLimit=15
	StartTime=-1
	StartTemperature=-1
	StartCloudCoverage=-1
	StartWeatherIntensity=-1
	WeatherProgression=true
	DayCycleProgression=true
	RespawnTime=3
	Lives=-1
}