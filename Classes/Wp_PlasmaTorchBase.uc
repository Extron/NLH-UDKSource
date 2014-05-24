/*******************************************************************************
	Wp_PlasmaTorchBase

	Creation date: 04/04/2014 09:55
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_PlasmaTorchBase extends ArenaWeaponBase;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'PlasmaTorch.Meshes.PT1Base'
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=6
		Values[WSVStability]=0.25
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
		Values[WSVAccuracy]=0.75
	End Object
	
	FireSound=SoundCue'PlasmaTorch.Audio.FireSC'
	
	DefaultComponents[WCStock]=class'Arena.Wp_S_CheapStock'
	DefaultComponents[WCBarrel]=class'Arena.Wp_B_PTShortBarrel'
	DefaultComponents[WCMuzzle]=class'Arena.Wp_M_NoMuzzle'
	DefaultComponents[WCOptics]=class'Arena.Wp_O_NoOptics'
	DefaultComponents[WCUnderAttachment]=class'Arena.Wp_UA_NoUnderAttachment'
	DefaultComponents[WCSideAttachment]=class'Arena.Wp_SA_NoSideAttachment'
	
	WeaponFireTypes[0]=EWFT_Projectile
	InstantHitDamageTypes[0]=None
	WeaponProjectiles[0]=class'Arena.Proj_PlasmaBall'
	AllowedFireModes[0]=FMSemiAuto
	FireModes[0]=FMSemiAuto
	CycleTime=0.15
	
	ViewOffset=(X=45, Y=10, Z=-22);
	BaseName="Plasma Torch Base"
	BaseDescription="A crude New World device, adopted from scavanged Old World schematics, the Plasma Torch serves little purpose other than to melt, burn, or set things on fire."
	Type=WTPlasmaRifle
	Size=WSLarge
	MaxAmmo=150
	MaxClip=10
	Ammo=60
	Clip=10
	BaseDamage=400
	Cost=75
}
