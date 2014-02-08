/*******************************************************************************
	WeaponSchematic

	Creation date: 01/07/2012 18:13
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponSchematic extends Object
	dependson(ArenaWeapon);

/* The base of the weapon. */
var class<ArenaWeaponBase> ArenaWeaponBase;

/* The stock of the weapon. */
var class<Wp_Stock> WeaponStock;

/* The barrel of the weapon. */
var class<Wp_Barrel> WeaponBarrel;

/* The muzzle of the weapon. */
var class<Wp_Muzzle> WeaponMuzzle;

/* The optics of the weapon. */
var class<Wp_Optics> WeaponOptics;

/* The side attachment of the weapon. */
var class<Wp_SideAttachment> WeaponSideAttachment;

/* The under attachment of the weapon. */
var class<Wp_UnderAttachment> WeaponUnderAttachment;

/* The name of the weapon schematic. */
var string WeaponName;

/**
 * The fire modes to set with the weapon.
 */
var array<FireMode> WeaponFireModes;

function SetSchematic(WeaponSchematicData data)
{
	ArenaWeaponBase = data.BaseClass;
	
	WeaponStock = class<Wp_Stock>(data.Components[WCStock]);
	WeaponBarrel = class<Wp_Barrel>(data.Components[WCBarrel]);
	WeaponMuzzle = class<Wp_Muzzle>(data.Components[WCMuzzle]);
	WeaponOptics = class<Wp_Optics>(data.Components[WCOptics]);
	WeaponSideAttachment = class<Wp_SideAttachment>(data.Components[WCSideAttachment]);
	WeaponUnderAttachment = class<Wp_UnderAttachment>(data.Components[WCUnderAttachment]);
	
	WeaponName = data.WeaponName;
	
	WeaponFireModes = data.FireModes;
}

defaultproperties
{
	WeaponStock=class'Arena.Wp_S_WoodStock'
	WeaponBarrel=class'Arena.Wp_B_BasicRifleBarrel'
	WeaponMuzzle=class'Arena.Wp_M_BasicRifleMuzzle'
	WeaponSideAttachment=class'Arena.Wp_SA_NoSideAttachment'
	WeaponUnderAttachment=class'Arena.Wp_UA_NoUnderAttachment'
	WeaponName="New Weapon"
	WeaponFireModes[0]=FMFullAuto
}