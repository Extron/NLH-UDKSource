/*******************************************************************************
	Wp_UA_Shotgun

	Creation date: 10/06/2013 01:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_UA_Shotgun extends Wp_UnderAttachment;

/**
 * This is the actual weapon that represents the shotgun.
 */
var Wp_UnderBarrelShotgun Weapon;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Weapon = Spawn(class'Arena.Wp_UnderBarrelShotgun', self);
}

simulated function Destroyed()
{
	super.Destroyed();
	
	Weapon.Destroy();
}

simulated function Toggle()
{	
	local ArenaPawn pawn;
	
	pawn = ArenaPawn(WeaponBase.Instigator);
	
	if (pawn.HeldWeapon == None)
		pawn.SwitchActiveWeapon(Weapon);
	else
		pawn.RevertActiveWeapon();
}

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'UAShotgun.Meshes.UAShotgunMesh'
	End Object
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[2]=WTHardLightRifle
	CompatibleTypes[5]=WTBeamRifle
	CompatibleTypes[6]=WTPlasmaRifle
	CompatibleTypes[7]=WTRailGun
	
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	Weight=4
	ComponentName="Shotgun"
	ComponentDescription="An under barrel shotgun that can provide additional firepower to the user, but will lower mobiliy of the weapon."
}