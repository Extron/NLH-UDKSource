/*******************************************************************************
	PlayerData

	Creation date: 12/08/2013 21:39
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Stores any globally constant player data, which is saved and loaded from binary files.
 */
class PlayerData extends Object
	dependson(ArenaWeapon);

struct WeaponSchematicData
{
	/**
	 * The weapon base class of the weapon.
	 */
	var class<ArenaWeaponBase> BaseClass;
	
	/**
	 * The component classes of the weapon.  This is indexed using the WeaponComponent enum.
	 */
	var array<class<ArenaWeaponComponent> > Components;
	
	/**
	 * The name of the weapon.
	 */
	var string WeaponName;
	
	/**
	 * The default fire modes of the weapon.
	 */
	var array<FireMode> FireModes;
};

struct WeaponData
{
	/**
	 * A list of weapon components the player has purchased.
	 */
	var array< class<ArenaWeaponComponent> > BoughtComponents;

	/**
	 * A list of weapon bases that the player has purchased.
	 */
	var array< class<ArenaWeaponBase> > BoughtBases;
	
	/**
	 * A list of saved weapon templates that the player has created.
	 */
	var array<WeaponSchematicData> WeaponLibrary;
};

struct BotBattleData
{
	/**
	 * The number of tokens that the player has in Bot Battle.
	 */
	var int Tokens;
};

struct LoadoutData
{
	/**
	 * The ability class that the loadout uses.
	 */
	var class<PlayerClass> AbilityClass;
	
	/**
	 * A list of the abilities that the loadout has.
	 */
	var array<class<ArenaAbility> > UnlockedAbilities;
	
	/**
	 * A list of the loadout's equipped abilities.
	 */
	var array<class<ArenaAbility> > EquippedAbilities;
	
	/**
	 * The name of the character class.
	 */
	var string LoadoutName;
	
	/**
	 * The name of the primary weapon schematic to use.  This data us stored in the player's weapon library.
	 */
	var string PrimaryWeaponName;
	
	/**
	 * The name of the character this class represents.
	 */
	var string CharacterName;
	
	/**
	 * The skill level of the character.
	 */
	var int Level;
	
	/**
	 * The amount of experience the character has.
	 */
	var int XP;
	
	/**
	 * The amount of xp points the character has to spend on abilities.
	 */
	var int Points;
};

/**
 * The current file version of the player data used.
 */
const FileVersion = 0;


/**
 * A list of the player's saved loadouts.
 */
var array<LoadoutData> Loadouts;

/**
 * Weapon data for the player, including a list of purchased weapon parts.
 */
var WeaponData WeapData;

/**
 * Data related to Bot Battle.
 */
var BotBattleData BBData;

/**
 * The amount of tokens that the player has.
 */
var int Cash;


simulated function Initialize()
{
	local WeaponSchematicData defaultWeap;
	
	WeapData.BoughtComponents[0] = class'Arena.Wp_S_NoStock';
	WeapData.BoughtComponents[1] = class'Arena.Wp_O_NoOptics';
	WeapData.BoughtComponents[2] = class'Arena.Wp_UA_NoUnderAttachment';
	WeapData.BoughtComponents[3] = class'Arena.Wp_SA_NoSideAttachment';
	
	WeapData.BoughtComponents[4] = class'Arena.Wp_S_CheapStock';
	WeapData.BoughtComponents[5] = class'Arena.Wp_O_CheapIronSights';
	WeapData.BoughtComponents[6] = class'Arena.Wp_B_BasicRifleBarrel';
	
	WeapData.BoughtBases[0] = class'Arena.Wp_BasicRifleBase';
	
	defaultWeap.BaseClass = class'Arena.Wp_BasicRifleBase';
	
	defaultWeap.Components[WCStock] = class'Arena.Wp_S_CheapStock';
	defaultWeap.Components[WCBarrel] = class'Arena.Wp_B_BasicRifleBarrel';
	defaultWeap.Components[WCMuzzle] = class'Arena.Wp_M_NoMuzzle';
	defaultWeap.Components[WCOptics] = class'Arena.Wp_O_CheapIronSights';
	defaultWeap.Components[WCUnderAttachment] = class'Arena.Wp_UA_NoUnderAttachment';
	defaultWeap.Components[WCSideAttachment] = class'Arena.Wp_SA_NoSideAttachment';
	defaultWeap.WeaponName = "Default Weapon";
	defaultWeap.FireModes[0] = FMFullAuto;
	
	WeapData.WeaponLibrary.AddItem(defaultWeap);
}