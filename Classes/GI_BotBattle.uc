/*******************************************************************************
	GI_BotBattle

	Creation date: 15/10/2012 14:54
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GI_BotBattle extends ArenaGameInfo;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Teams[0] = Spawn(class'TI_BotWave');
	
	SpawnOrb();
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
	
	bot = Spawn(botClass);
	spawnPoint = FindPlayerStart(bot, 1);
	
	botPawn = Spawn(pawnClass, , , spawnPoint.Location);
	
	if (botPawn == None)
		`log("Pawn None!");
		
	bot.Possess(botPawn, false);
	wave.AddToTeam(bot);
}

function SpawnOrb()
{
	SpawnBot(class'ArenaBot', class'AP_OrbBot', Teams[0]);
}