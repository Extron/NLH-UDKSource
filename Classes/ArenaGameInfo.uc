/*******************************************************************************
	ArenaGameInfo

	Creation date: 30/06/2012 16:51
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This forms the base for all Arena gametypes.  
 */
class ArenaGameInfo extends UDKGame;


/** The teams for the game. */
var array<ArenaTeamInfo> Teams;

/** The class of the team info to use for the teams. */
var class<ArenaTeamInfo> TeamInfoClass;

/** The respawn time for all players during this gametype. */
var float RespawnTime;

/** Indicates that the player can fast respawn (spawn immidiately) during this gametype. */
var bool AllowFastRespawn;

/** Indicates that dead players can respawn. */
var bool CanRespawn;

/** Forces the player to respawn after the respawn timer ends. */
var bool ForceRespawn;

/** Indicates that the server manages team balance. */
var bool AutoBalance;

/** The maximum number of teams allowed for the game. */
var int MaxTeams;


function PostBeginPlay()
{
	super.PostBeginPlay();
	
	SetGameReplicationInfo();
}

/**
 * This sets the GRI variables to be consistent with the game info variables every tick.
 */
function SetGameReplicationInfo()
{
	if (ArenaGRI(GameReplicationInfo) != None)
	{
		ArenaGRI(GameReplicationInfo).RespawnTime = RespawnTime;
		ArenaGRI(GameReplicationInfo).AllowFastRespawn = AllowFastRespawn;
		ArenaGRI(GameReplicationInfo).CanRespawn = CanRespawn;
		ArenaGRI(GameReplicationInfo).ForceRespawn = ForceRespawn;
	}
}

function CreateTeam(string tName)
{
	local ArenaTeamInfo team;
	
	if (Teams.Length < MaxTeams)
	{
		team = spawn(TeamInfoClass);
		//team.TeamName = tName;
		
		Teams.AddItem(team);
	}
}

defaultproperties
{
	PlayerControllerClass=class'Arena.ArenaPlayerController'
	DefaultPawnClass=class'Arena.AP_Player'
	HUDType=class'Arena.ArenaHUD'
	GameReplicationInfoClass=class'Arena.ArenaGRI'
	PlayerReplicationInfoClass=class'Arena.ArenaPRI'
	//bDelayedStart=true
	
	RespawnTime=3
	AllowFastRespawn=false
	CanRespawn=true
	ForceRespawn=true
}