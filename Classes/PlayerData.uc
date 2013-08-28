/*******************************************************************************
	PlayerData

	Creation date: 12/08/2013 21:39
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Stores any globally constant player data, which is saved and loaded from binary files.
 */
class PlayerData extends Object;

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
};

struct BotBattleData
{
	/**
	 * The number of tokens that the player has in Bot Battle.
	 */
	var int Tokens;
};


/**
 * The current file version of the player data used.
 */
const FileVersion = 0;

/**
 * Weapon data for the player, including a list of purchased weapon parts.
 */
var WeaponData WeapData;

/**
 * Data related to Bot Battle.
 */
var BotBattleData BBData;


simulated function Initialize()
{
	WeapData.BoughtComponents[0] = class'Arena.Wp_S_NoStock';
	WeapData.BoughtComponents[1] = class'Arena.Wp_O_NoOptics';
	WeapData.BoughtComponents[2] = class'Arena.Wp_UA_NoUnderAttachment';
	WeapData.BoughtComponents[3] = class'Arena.Wp_SA_NoSideAttachment';
	
	WeapData.BoughtComponents[4] = class'Arena.Wp_S_CheapStock';
	WeapData.BoughtComponents[5] = class'Arena.Wp_O_CheapIronSights';
	WeapData.BoughtComponents[6] = class'Arena.Wp_B_BasicRifleBarrel';
	
	WeapData.BoughtBases[0] = class'Arena.Wp_BasicRifleBase';
}