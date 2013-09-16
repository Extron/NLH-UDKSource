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
 * The model that the loadout uses.
 */
var PlayerModel Model;

/**
 * The ability class of the player.
 */
var class<PlayerClass> AbilityClass;

/** 
 * The name of the loadout.
 */
var string LoadoutName;

/**
 * The name of the character this class represents.
 */
var string CharacterName;

/**
 * The amount of ability experience that the player has gained, used for obtaining new abilities.
 */
var int XP;

/**
 * The amount of cash the player has obtained, used for buying weapons and armor.
 */
var int Cash;



defaultproperties
{
	LoadoutName="Custom Loadout"
	AbilityClass=class'Arena.PC_Electricity'
}