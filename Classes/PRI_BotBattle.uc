/*******************************************************************************
	PRI_BotBattle

	Creation date: 20/06/2013 17:24
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PRI_BotBattle extends ArenaPRI;


/**
 * A list of weapon bases that the player has unlocked.
 */
var array<class<ArenaWeaponBase> > UnlockedBases;

/**
 * A list of weapon stocks that the player has unlocked.
 */
var array<class<Wp_Stock> > UnlockedStocks;

/**
 * A list of weapon barrels that the player has unlocked.
 */
var array<class<Wp_Barrel> > UnlockedBarrels;

/**
 * A list of weapon muzzles that the player has unlocked.
 */
var array<class<Wp_Muzzle> > UnlockedMuzzles;

/**
 * A list of weapon optics that the player has unlocked.
 */
var array<class<Wp_Optics> > UnlockedOptics;

/**
 * A list of weapon under attachments that the player has unlocked.
 */
var array<class<Wp_UnderAttachment> > UnlockedUnders;

/**
 * A list of weapon side attachments that the player has unlocked.
 */
var array<class<Wp_SideAttachment> > UnlockedSides;

/**
 * A list of abilities that the player has unlocked.
 */
var array<class<ArenaAbility> > UnlockedAbilities;

/**
 * The number of tokens that the player has accumulated.  Tokens are earned by finishing waves, harking terminals, and 
 * getting kills in stylized ways.
 */
var int Tokens;


simulated function AwardTokens(int number)
{
	Tokens += number;
}

simulated function SpendTokens(int number)
{
	Tokens -= number;
}