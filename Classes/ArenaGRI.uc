/*******************************************************************************
	TestGRI

	Creation date: 15/08/2012 20:03
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaGRI extends GameReplicationInfo;


/** The game's constants. */
var GlobalGameConstants Constants;

/** The respawn time for all players. */
var float RespawnTime;

/** The current time of day, measured from 0 (midnight) to 2 pi. */
var float TimeOfDay; 

/** Keeps track of how fast the time of day changes. */
var float DayRate;

/** The percent of cloud coverage in the sky. */
var float CloudCoverage;

/** The sharpness of the clouds. */
var float CloudSharpness;

/** Indicates that the player can respawn immidiately after death. */
var bool AllowFastRespawn;

/** Indicates that the player can respawn. */
var bool CanRespawn;

/** Force the player to respawn. */
var bool ForceRespawn;


replication
{
	if (bNetInitial)
		Constants;
		
	if (bNetDirty)
		RespawnTime, AllowFastRespawn, CanRespawn, TimeOfDay, CloudCoverage, CloudSharpness;
}

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	//TimeOfDay += dt * DayRate;
	
	CloudCoverage = Cos(TimeOfDay * 0.25) * Cos(TimeOfDay * 0.25);
	
	if (TimeOfDay > 2 * Pi)
		TimeOfDay = 0;
}

defaultproperties
{
	Begin Object Class=GlobalGameConstants Name=NewConstants
	End Object
	Constants=NewConstants
	
	TimeOfDay=1
	DayRate=0.1
	CloudCoverage=0
	CloudSharpness=0.001
}