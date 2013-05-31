/*******************************************************************************
	BasicRifleBase

	Copyright (c) 2012, Trystan
	Creation date: 09/07/2012 23:00
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_BasicRifleBase extends ArenaWeaponBase;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'BasicRifleBase.Meshes.RifleBaseMesh_1P'
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=4
		Values[WSVStability]=0.25
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
	End Object
	
	WeaponFireTypes(0)=EWFT_Projectile
	InstantHitDamageTypes(0)=None
	WeaponProjectiles(0)=class'Arena.Proj_RifleBullet'
	Mode=FMFullAuto
	CycleTime=0.25
	BurstCount=3
	
	FireSound=SoundCue'BasicRifleBase.Audio.GunshotSC'
	
	PlayerAnimSet=AnimSet'AC_Player.Animations.PlayerAnim'
	
	ViewOffset=(X=45, Y=5, Z=-22);
	ArenaWeaponBaseName="Basic Rifle Base"
	BaseDescription="A relic from the Old World, this rifle base is your basic projectile-based weapon.  Surprisingly durable, it supports many components, ammo types, and firing modes."
	Energy=0
	Type=WTRifle
	Size=WSRegular
	MaxAmmo=300
	MaxClip=30
	Ammo=300
	Clip=30
	BaseDamage=150
}