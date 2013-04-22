/*******************************************************************************
	PlayerLoadout

	Creation date: 01/07/2012 18:08
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PlayerLoadout extends Object;

enum PlayerModel
{
	PMPurebreed,
	PMHybrid,
	PMMutt
};

/**
 * The schematic of the weapon to use with this loadout. 
 */
var WeaponSchematic Weapon;

/**
 * The ability class of the player.
 */
var class<PlayerClass> AbilityClass;

/** 
 * The name of the loadout.
 */
var string LoadoutName;

/**
 * The model that the loadout uses.
 */
var PlayerModel Model;


defaultproperties
{
	LoadoutName="Custom Loadout"
	AbilityClass=class'Arena.PC_Electricity'
}