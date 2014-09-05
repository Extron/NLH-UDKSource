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
		WaveManager.Initialize(self);
		
		for (i = 0; i < WaveManager.Waves.Length; i++)
		{
			WaveManager.Waves[i].WaveTI = Spawn(class'TI_BotWave');
			WaveManager.Waves[i].WaveTI.Parent = WaveManager.Waves[i];
			WaveManager.Waves[i].WaveTI.TeamIndex = i + 1;
			
			Teams[i + 1] = WaveManager.Waves[i].WaveTI;
		}
		
		if (WaveManager.AutoBegin && !InitialIntermission)
			SetTimer(WaveManager.IntermissionTime, false, 'SpawnWave');
	}
}

simulated function StartGame()
{
	super.StartGame();
	
	SetTimer(WaveManager.IntermissionTime, false, 'SpawnWave');
}

function Tick(float dt)
{
	if (WaveManager.Intermission)
	{
		GRI_BotBattle(GameReplicationInfo).IntermissionTime = WaveManager.GetRemainingTimeForTimer('SpawnNextWave');
	}
	else
	{
		GRI_BotBattle(GameReplicationInfo).IntermissionTime = -1;
	}
}

function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	local array<string> killMessage;
	local array<int> messageColors;
	local BotKillDisplay display;
	local float points;
	local int tokens;
	local int i;
	
    super.Killed(Killer, KilledPlayer, KilledPawn, DamageType);
	
	if (ArenaPlayerController(Killer) != None && ArenaBot(KilledPlayer) != None)
	{
		display = Spawn(class'Arena.BotKillDisplay', None, , KilledPawn.Location);
		
		ComputePointsAndTokens(AP_Bot(KilledPawn), class<ArenaDamageType>(damageType), points, tokens);
		
		if (class<ArenaDamageType>(damageType) != None)
		{
			killMessage.AddItem("Bot" @ class<ArenaDamageType>(damageType).default.ActionString);
			messageColors.AddItem(class<ArenaDamageType>(damageType).default.DisplayColor);
		}
		else
		{
			killMessage.AddItem("Bot killed");
			messageColors.AddItem(0xFFFFFF);
		}
		
		for (i = 0; i < AP_Bot(KilledPawn).ActiveEffects.Length; i++)
		{
			if (AP_Bot(KilledPawn).ActiveEffects[i] != None)
			{
				/*
				if (AP_Bot(KilledPawn).ActiveEffect.Combinations > 1)
				{
					killMessage.AddItem("Effect Combo!");
					messageColors.AddItem(0xFFFF00);
				}*/
				
				killMessage.AddItem(AP_Bot(KilledPawn).ActiveEffects[i].EffectName);
				messageColors.AddItem(AP_Bot(KilledPawn).ActiveEffects[i].DisplayColor);
			}
		}
		
		`log("Points" @ points @ "Tokens" @ tokens);
		
		display.KillDisplay.SetDisplay(killMessage, messageColors, points, tokens);
	}
}

function PlayerController SpawnPlayerController(vector SpawnLocation, rotator SpawnRotation)
{
	local PlayerController player;
	
	player = super.SpawnPlayerController(SpawnLocation, SpawnRotation);
	
	if (player != None)
	{
		Teams[0].AddToTeam(player);
	}
	
	return player;
}

simulated function SpawnWave()
{
	if (WaveManager != None && !WaveManager.AllWavesComplete())
		WaveManager.SpawnNextWave();
}

simulated function WaveSpawned(BBWaveComponent wave)
{
	local ArenaPlayerController iter;
	
	if (GRI_BotBattle(GameReplicationInfo) != None)
	{
		GRI_BotBattle(GameReplicationInfo).CurrentWave++;
	
		foreach WorldInfo.AllControllers(class'Arena.ArenaPlayerController', iter)
		{
			if (ArenaHUD(iter.MyHUD) != None)
				ArenaHUD(iter.MyHUD).QueueAlert("Beginning Wave" @ GRI_BotBattle(GameReplicationInfo).CurrentWave, 2);
		}
	}	
}

simulated function WaveComplete(BBWaveComponent wave)
{
	local ArenaPlayerController iter;
	
	foreach WorldInfo.AllControllers(class'Arena.ArenaPlayerController', iter)
	{
			iter.AwardBBTokens(5);
			
		if (ArenaHUD(iter.MyHUD) != None)
			ArenaHUD(iter.MyHUD).QueueAlert("Wave Complete", 2);
	}
}

simulated function ComputePointsAndTokens(AP_Bot killedBot, class<ArenaDamageType> damage, out float points, out int tokens)
{
	local int i;
	
	if (damage != None)
	{
		points = damage.default.Points;
		
		for (i = 0; i < killedBot.ActiveEffects.Length; i++)
		{
			if (killedBot.ActiveEffects[i] != None)
			{
				if (class<StatusDamageType>(damage) != None)
					points += killedBot.ActiveEffects[i].KilledByPoints;
				else
					points += killedBot.ActiveEffects[i].KilledWhilePoints;
					
				/*if (killedBot.ActiveEffect.Combinations > 1)
					tokens += FFloor(killedBot.ActiveEffect.Combinations / 2);*/
			}
		}
	}
	else
	{
		points = 1;
		tokens = 0;
	}
}

defaultproperties
{
	PlayerControllerClass=class'Arena.ArenaPlayerController'
	DefaultPawnClass=class'Arena.AP_Player'
	HUDType=class'Arena.HUD_BotBattle'
	GameReplicationInfoClass=class'Arena.GRI_BotBattle'
	PlayerReplicationInfoClass=class'Arena.PRI_BotBattle'
	//bDelayedStart=true
	InitialIntermission=true
	InitialIntermissionTime=5
	SettingsClass=class'Arena.GISettings_BotBattle'
	
	RespawnTime=3
	AllowFastRespawn=false
	CanRespawn=true
	ForceRespawn=true
}