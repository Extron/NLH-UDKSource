/*******************************************************************************
	TestGRI

	Creation date: 15/08/2012 20:03
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaGRI extends GameReplicationInfo;


/** The game's constants. */
var GlobalGameConstants Constants;

/**
 * The game's settings.
 */
var GISettings GameSettings;

/** The respawn time for all players. */
var float RespawnTime;

/**
 * The game's weather manager.
 */
var WeatherManager WeatherMgr;

/** Indicates that the player can respawn immidiately after death. */
var bool AllowFastRespawn;

/** Indicates that the player can respawn. */
var bool CanRespawn;

/** Force the player to respawn. */
var bool ForceRespawn;


replication
{
	if (bNetInitial)
		Constants, GameSettings;
		
	if (bNetDirty)
		RespawnTime, AllowFastRespawn, CanRespawn, WeatherMgr;
}

simulated function PostBeginPlay()
{
	local WeatherManager iter;
	
	foreach AllActors (class'Arena.WeatherManager', iter)
	{
		if (iter != None)
		{
			WeatherMgr = iter;
			break;
		}
	}

}

simulated function StartMatch()
{
	super.StartMatch();
	SetSettings();
}

simulated function ReplicatedEvent(name property)
{
	super.ReplicatedEvent(property);

	if (property == nameof(GameSettings))
	{
		`log("Game Settings replicated");
		SetSettings();
	}
}

/**
 * Uses the current values in GameSettings to set various game properties.
 */
simulated function SetSettings()
{
	if (GameSettings != None)
	{
		WeatherMgr.TickDay = GameSettings.DayCycleProgression;
		WeatherMgr.TickWeather = GameSettings.WeatherProgression;
		
		`log("Tick Weather" @ WeatherMgr.TickWeather @ GameSettings.WeatherProgression);
		
		if (GameSettings.StartTime < 0)
			WeatherMgr.TimeOfDay = FRand() * 3.14159;
		else
			WeatherMgr.TimeOfDay = GameSettings.StartTime * 3.14159;
			
		
		if (GameSettings.StartCloudCoverage < 0)
			WeatherMgr.StartCloudCoverage = FRand();
		else
			WeatherMgr.StartCloudCoverage = 1 - GameSettings.StartCloudCoverage;
			
		`log("Cloud Coverage" @ WeatherMgr.CloudCoverage @ GameSettings.StartCloudCoverage);
		
		if (GameSettings.StartTemperature < 0)
			WeatherMgr.StartTemperature = FRand();
		else
			WeatherMgr.StartTemperature = GameSettings.StartTemperature;
			
		if (GameSettings.StartWeatherIntensity < 0)
			WeatherMgr.StartWeatherIntensity = FRand();
		else
			WeatherMgr.StartWeatherIntensity = GameSettings.StartWeatherIntensity;
	}
}

defaultproperties
{
	Begin Object Class=GlobalGameConstants Name=NewConstants
	End Object
	Constants=NewConstants
}