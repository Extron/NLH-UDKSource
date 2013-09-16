/*******************************************************************************
	Wp_AssaultRifleBase

	Creation date: 12/09/2013 01:01
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_AssaultRifleBase extends ArenaWeaponBase;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'AssaultRifleBase.Meshes.AssaultRifleBaseMesh'
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=4
		Values[WSVStability]=0.25
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
	End Object
	
	DefaultComponents[WCStock]=class'Arena.Wp_S_CheapStock'
	DefaultComponents[WCBarrel]=class'Arena.Wp_B_ShortRailedBarrel'
	DefaultComponents[WCMuzzle]=class'Arena.Wp_M_NoMuzzle'
	DefaultComponents[WCOptics]=class'Arena.Wp_O_CheapIronSights'
	DefaultComponents[WCUnderAttachment]=class'Arena.Wp_UA_NoUnderAttachment'
	DefaultComponents[WCSideAttachment]=class'Arena.Wp_SA_NoSideAttachment'
	
	WeaponFireTypes(0)=EWFT_Projectile
	InstantHitDamageTypes(0)=None
	WeaponProjectiles(0)=class'Arena.Proj_RifleBullet'
	AllowedFireModes[0]=FMFullAuto
	AllowedFireModes[1]=FMBurst
	AllowedFireModes[2]=FMSemiAuto
	FireModes[0]=FMFullAuto
	Mode=0
	CycleTime=0.25
	BurstCount=3
	
	FireSound=SoundCue'BasicRifleBase.Audio.GunshotSC'
	
	//PlayerAnimSet=AnimSet'AC_Player.Animations.ArmsAnimSet'
	
	ViewOffset=(X=45, Y=5, Z=-22);
	BaseName="Assault Rifle Base"
	BaseDescription="A relic from the Old World, this rifle base is your basic projectile-based weapon.  Surprisingly durable, it supports many components, ammo types, and firing modes."
	Type=WTRifle
	Size=WSRegular
	MaxAmmo=300
	MaxClip=30
	Ammo=300
	Clip=30
	BaseDamage=150
}