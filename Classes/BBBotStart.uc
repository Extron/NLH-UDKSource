/*******************************************************************************
	BBBotStart

	Creation date: 04/04/2013 17:42
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Represents the spawn point for bots to use in Bot Battle.
 */
class BBBotStart extends PlayerStart;

/**
 * The bot types that are allowed to spawn at this spawn point.
 */
var(Spawn) array<class<AP_Bot> > AllowedBots;

/**
 * The waves that are allowed to use this spawn point.
 */
var(Spawn) array<int> AllowedWaves;

/**
 * Determines if a bot from a specified wave can use this spawn point.
 */
simulated function bool CanBotSpawnHere(class<AP_Bot> botClass, int wave)
{
	return AllowedBots.Find(botClass) > -1 && AllowedWaves.Find(wave) > -1;
}