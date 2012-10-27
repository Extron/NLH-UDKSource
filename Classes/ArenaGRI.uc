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
		RespawnTime, AllowFastRespawn, CanRespawn;
}

defaultproperties
{
	Begin Object Class=GlobalGameConstants Name=NewConstants
	End Object
	Constants=NewConstants
}