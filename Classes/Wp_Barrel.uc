/*******************************************************************************
	Barrel

	Creation date: 07/07/2012 14:52
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Barrel extends ArenaWeaponComponent;


/**
 * The muzzle flash that the barrel emits when the weapon is fired.
 */
var ParticleSystem MuzzleFlashTemplate;

/**
 * The light to use for the muzzle flash.
 */
var class<UDKExplosionLight> MFLClass;

/**
 * Since barrels may have iron sight posts, this allows them to specify an offset to line up the post and aperature with.
 */
var vector SightsOffset;


simulated function bool CanAttachToBase(ArenaWeaponBase baseWeap)
{
	return super.CanAttachToBase(baseWeap) && baseWeap.CanEquipBarrel(self);
}

/**
 * As some barrels will not be able to feasibly support muzzles, check that we can attach
 * a muzzle to the barrel.
 */
simulated function bool CanEquipMuzzle(Wp_Muzzle muzzle)
{
	return true;
}

/**
 * As some barrels will not be able to feasibly support attachments, check that we can attach
 * an under-barrel attachment to the barrel.
 */
simulated function bool CanEquipUnderAttachment(Wp_UnderAttachment attachment)
{
	return true;
}

/**
 * As some barrels will not be able to feasibly support attachments, check that we can attach
 * a side-barrel attachment to the barrel.
 */
simulated function bool CanEquipSideAttachment(Wp_SideAttachment attachment)
{
	return true;
}

defaultproperties
{
	Subclasses[0]=class'Arena.Wp_B_NoBarrel'
	Subclasses[1]=class'Arena.Wp_B_ShortSimpleBarrel'
	Subclasses[2]=class'Arena.Wp_B_SpinningBarrel'
	Subclasses[3]=class'Arena.Wp_B_CrossbowBarrel'
}