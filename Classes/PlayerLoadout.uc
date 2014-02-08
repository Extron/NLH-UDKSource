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
var WeaponSchematic PrimaryWeapon;

/**
 * The model that the loadout uses.
 */
var PlayerModel Model;

/**
 * A list of abilities this loadout has equipped.
 */
var array<class<ArenaAbility> > Abilities;

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
 * The skill level of the character.
 */
var int Level;

/**
 * The amount of ability experience that the player has gained, used for obtaining new abilities.
 */
var int XP;

/**
 * The amount of cash the player has obtained, used for buying weapons and armor.
 */
var int Cash;


function SetLoadout(LoadoutData data, ArenaPlayerController owner)
{
	local int i;
	
	AbilityClass = data.AbilityClass;
	CharacterName = data.CharacterName;
	Level = data.Level;
	XP = data.XP;
	
	if (PrimaryWeapon == None)
		PrimaryWeapon = new class'Arena.WeaponSchematic';
		
	PrimaryWeapon.SetSchematic(owner.GetWeapon(data.PrimaryWeaponName));
	
	for (i = 0; i < data.EquippedAbilities.Length; i++)
		Abilities.AddItem(data.EquippedAbilities[i]);
		
	Model = PMPurebreed;
}

defaultproperties
{
	LoadoutName="Custom Loadout"
	AbilityClass=class'Arena.PC_Electricity'
}