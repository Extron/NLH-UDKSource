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
	var() class<ArenaPawn> PawnType;
	
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

simulated function SpawnWave()
{
	local int i;
	local int j;
	
	for (i = 0; i < Bots.Length; i++)
	{
		for (j = 0; j < Bots[i].WaveActive; j++)
		{
			`log("Spawning bot in wave.");
			
			SpawnBot(Bots[i].BotType, Bots[i].PawnType, WaveTI);
			Bots[i].TotalCount++;
			Bots[i].ActiveCount++;
		}
	}
}

/**
 * Spawns a new bot.
 *
 * @param botClass - The bot class to spawn.
 * @param pawnClass - The pawn class to use for the bot.
 * @param wave - The wave to add this bot to.
 */
simulated event SpawnBot(class<ArenaBot> botClass, class<ArenaPawn> pawnClass, ArenaTeamInfo wave)
{
	local ArenaBot bot;
	local ArenaPawn botPawn;
	local NavigationPoint spawnPoint;
	
	bot = Parent.Spawn(botClass);
	spawnPoint = Parent.Parent.FindPlayerStart(bot, 1);
	
	botPawn = Parent.Spawn(pawnClass, , , spawnPoint.Location);
	
	if (botPawn == None)
		`warn("Pawn None!");
		
	bot.Possess(botPawn, false);
	wave.AddToTeam(bot);
}

simulated event KillBot(ArenaBot bot)
{
	local int i;
	
	for (i = 0; i < Bots.Length; i++)
	{
		if (bot.IsA(Bots[i].BotType.Name) && bot.Pawn.IsA(Bots[i].PawnType.Name))
		{
			if (Bots[i].TotalCount < Bots[i].WaveTotal)
			{				
				`log("Spawning new bot.");
				
				SpawnBot(Bots[i].BotType, Bots[i].PawnType, WaveTI);
				Bots[i].TotalCount++;
			}			
		}
	}
}

defaultproperties
{
}