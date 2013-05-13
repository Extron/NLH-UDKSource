/*******************************************************************************
	GI_BotBattle

	Creation date: 15/10/2012 14:54
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GI_BotBattle extends ArenaGameInfo;

/** The game's wave manager, which provides what bots should show up in what waves, and how long each wave is. */
var BBWaveManager WaveManager;


function PostBeginPlay()
{
	local BBWaveManager iter;
	local int i;
	
	super.PostBeginPlay();
	
	foreach AllActors (class'Arena.BBWaveManager', iter)
	{
		if (iter != None)
		{
			WaveManager = iter;
			break;
		}
	}
	
	Teams[0] = Spawn(class'TI_BBPlayers');
	Teams[0].TeamIndex = 0;
	
	if (WaveManager != None)
	{		
		`log("Initializing waves.");
		
		WaveManager.Initialize(self);
		
		for (i = 0; i < WaveManager.Waves.Length; i++)
		{
			WaveManager.Waves[i].WaveTI = Spawn(class'TI_BotWave');
			WaveManager.Waves[i].WaveTI.Parent = WaveManager.Waves[i];
			WaveManager.Waves[i].WaveTI.TeamIndex = i + 1;
			
			Teams[i + 1] = WaveManager.Waves[i].WaveTI;
		}
		
		if (WaveManager.AutoBegin)
		{
			`log("Beginning the first wave in" @ WaveManager.IntermissionTime @ "seconds.");
			
			SetTimer(WaveManager.IntermissionTime, false, 'SpawnWave');
		}
	}
}

function PlayerController SpawnPlayerController(vector SpawnLocation, rotator SpawnRotation)
{
	local PlayerController player;
	
	player = super.SpawnPlayerController(SpawnLocation, SpawnRotation);
	
	if (player != None)
		Teams[0].AddToTeam(player);
	
	return player;
}

simulated function SpawnWave()
{
	`log("Wave timer completed.");
	
	`log("Waves complete?" @ WaveManager.AllWavesComplete());
	
	if (WaveManager != None && !WaveManager.AllWavesComplete())
		WaveManager.SpawnNextWave();
		
	if (GRI_BotBattle(GameReplicationInfo) != None)
	{
		GRI_BotBattle(GameReplicationInfo).CurrentWave++;
	}
}

defaultproperties
{
	PlayerControllerClass=class'Arena.ArenaPlayerController'
	DefaultPawnClass=class'Arena.AP_Player'
	HUDType=class'Arena.HUD_BotBattle'
	GameReplicationInfoClass=class'Arena.GRI_BotBattle'
	PlayerReplicationInfoClass=class'Arena.ArenaPRI'
	//bDelayedStart=true
	
	RespawnTime=3
	AllowFastRespawn=false
	CanRespawn=true
	ForceRespawn=true
}