/*******************************************************************************
	BBWaveComponent

	Creation date: 29/12/2012 14:48
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BBWaveComponent extends ActorComponent editinlinenew;

struct WaveBot
{
	/** The type of the controller fro the bot. */
	var() class<ArenaBot> BotType;
	
	/** The type of the bot's pawn. */
	var() class<AP_Bot> PawnType;
	
	/** The amount of bots of the specified type to spawn in a wave. */
	var() int WaveTotal;
	
	/** The amount of bots of the specifiet type to have active at any one
	  * time during the wave. */
	var() int WaveActive;
	
	/** The amount of bots that have been spawned this wave. */
	var int TotalCount;
	
	/** The amount of bots currently active. */
	var int ActiveCount;
};

/** 
 * This is a list of bot types that are queued to be spawned.  The index corresponds to the bot type in the Bots list.
 */
var array<int> QueuedBots;

/** The bots that are in the wave. */
var() editinline array<WaveBot> Bots;

/** The maximum amount of bots of any type allowed in the wave. */
var() int MaxBotsTotal;

/** The wave manager that owns this wave. */
var BBWaveManager Parent;

/** The team object that manages the wave. */
var TI_BotWave WaveTI;

/** Indicates whether this wave is complete or not. */
var bool Complete;

simulated function Initialize(BBWaveManager waveManager)
{
	Parent = waveManager;
}

simulated function UpdateWave()
{
	local int i, j;
	local int spawnCount;

	for (i = 0; i < Bots.Length; i++)
	{
		if (Bots[i].ActiveCount < Bots[i].WaveActive && Bots[i].TotalCount < Bots[i].WaveTotal)
		{	
			spawnCount = Min(Bots[i].WaveActive - Bots[i].ActiveCount, Bots[i].WaveTotal - Bots[i].TotalCount);
			
			for (j = 0;  j < spawnCount; j++)
			{
				if (SpawnBot(i, Bots[i].BotType, Bots[i].PawnType, WaveTI))
				{
					Bots[i].ActiveCount++;
					Bots[i].TotalCount++;
				}
			}
		}
	}
}

simulated function SpawnWave()
{
	local int i;
	local int j;
	
	for (i = 0; i < Bots.Length; i++)
	{
		for (j = 0; j < Bots[i].WaveActive; j++)
		{
			`log("Spawning bot in wave.");
			
			if (SpawnBot(i, Bots[i].BotType, Bots[i].PawnType, WaveTI))
			{
				Bots[i].TotalCount++;
				Bots[i].ActiveCount++;
			}
		}
	}
}

simulated function bool FindUnusedSpawn(class<AP_Bot> pawnClass, ArenaTeamInfo wave, out vector spawnLoc)
{
	local BBBotStart sp, start;
	local Actor iter, b;

	foreach Parent.WorldInfo.AllNavigationPoints(class'Arena.BBBotStart', sp)
	{
		if (sp.CanBotSpawnHere(pawnClass, wave.TeamIndex))
		{
			foreach Parent.VisibleCollidingActors(class'Actor', iter, pawnClass.Default.CylinderComponent.CollisionRadius, sp.Location)
			{
				if (Volume(iter) == None) 
					b = iter;
			}
			
			if (b == None)
				start = sp;
		}
	
	}
	
	if (start != None)
	{
		spawnLoc = start.Location;
		return true;
	}
	
	spawnLoc = vect(0, 0, 0);
	return false;
}

/**
 * Spawns a new bot.
 *
 * @param botClass - The bot class to spawn.
 * @param pawnClass - The pawn class to use for the bot.
 * @param wave - The wave to add this bot to.
 */
simulated event bool SpawnBot(int botIndex, class<ArenaBot> botClass, class<AP_Bot> pawnClass, ArenaTeamInfo wave)
{
	local ArenaBot bot;
	local ArenaPawn botPawn;
	local vector spawnPoint;
	
	if (FindUnusedSpawn(pawnClass, wave, spawnPoint))
	{
		bot = Parent.Spawn(botClass);
		
		botPawn = Parent.Spawn(pawnClass, , , spawnPoint);
		
		if (botPawn == None)
			`warn("Pawn None!");
			
		bot.Possess(botPawn, false);
		wave.AddToTeam(bot);
		return true;
	}
	else
	{
		//`log("Could not spawn bot.");
		QueuedBots.AddItem(botIndex);
		return false;
	}
}

simulated event KillBot(ArenaBot bot)
{
	local int i;
	
	for (i = 0; i < Bots.Length; i++)
	{
		if (bot.IsA(Bots[i].BotType.Name) && bot.Pawn.IsA(Bots[i].PawnType.Name))
		{
			Bots[i].ActiveCount--;	
			break;
		}
	}
	
	IsComplete();
}

simulated function IsComplete()
{
	local int i;
	
	for (i = 0; i < Bots.Length; i++)
	{
		if (!(Bots[i].TotalCount >= Bots[i].WaveTotal && Bots[i].ActiveCount <= 0))
			return;
	}
	
	Complete = true;
}

defaultproperties
{
}