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


defaultproperties
{
	Subclasses[0]=class'Arena.Wp_B_BasicRifleBarrel'
}