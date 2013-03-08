/*******************************************************************************
	BotPersonality

	Creation date: 03/03/2013 03:02
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This class stores data on bot personalities, such as aggresion, cowardice, and intelligence.
 */
class BotPersonality extends Object;


/**
 * This determines how likely a bot is to attack, especially under risky or reckless situations.  It also
 * is a measure for how a bot will respond to events like being shot at, seeing allies die, persuing enemiets, etc.
 */
var float Aggression;

/**
 * This determines how often the bot will retreat from a combat situation.  Bots with a high cowardice will have a much
 * lower tolerance for dangerous situations, and will often run at the first sign of danger.
 */
var float Cowardice;

/**
 * This determines how far ahead a bot will plan, and especially affects how the bot searches for a player, as well as likely
 * the bot is to noticing the player through sight and sound.
 */
var float Intelligence;

/**
 * This trait affects how a bot will react to dangerous situations.  A brave bot will often fight even when there is little chance
 * of victory, and will rarely retreat.
 */
var float Bravery;

/**
 * A bot with high charisma will drastically affect bots around it, often motivating them to fight harder.
 */
var float Charisma;