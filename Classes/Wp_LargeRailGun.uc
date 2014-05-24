/*******************************************************************************
	Wp_LargeRailGun

	Creation date: 10/05/2014 01:24
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Wp_LargeRailGun extends ArenaWeaponBase;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RailGun.Meshes.LargeRailGunBase'
		AnimSets[0]=AnimSet'RailGun.Animations.LRGAnimations'
		AnimTreeTemplate=AnimTree'RailGun.Animations.LRGAnimationTree'
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=10
		Values[WSVStability]=0.25
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
		Values[WSVAccuracy]=0.75
	End Object
	
	DefaultComponents[WCStock]=class'Arena.Wp_S_CheapStock'
	DefaultComponents[WCBarrel]=class'Arena.Wp_B_CrossbowBarrel'
	DefaultComponents[WCMuzzle]=class'Arena.Wp_M_NoMuzzle'
	DefaultComponents[WCOptics]=class'Arena.Wp_O_VIronSights'
	DefaultComponents[WCUnderAttachment]=class'Arena.Wp_UA_NoUnderAttachment'
	DefaultComponents[WCSideAttachment]=class'Arena.Wp_SA_NoSideAttachment'
	
	WeaponFireTypes[0]=EWFT_InstantHit
	InstantHitDamageTypes[0]=class'Arena.Dmg_RailGunSlug'
	InstantHitMomentum[0]=1000
	FireModes[0]=FMSemiAuto
	AllowedFireModes[0]=FMSemiAuto
	CycleTime=2.5
	BurstCount=1
	
	FireSound=SoundCue'RailGun.Audio.FireSC'
	IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.PhotonBeam'
	
	FireAnims[0]=Fire
	
	MuzzleFlashTemplate=ParticleSystem'RailGun.Particles.MuzzleFlash'
	
	ViewOffset=(X=45, Y=10, Z=-22);
	BaseName="Large Rail Gun"
	BaseDescription="A hybrid weapon that incorperates Old World technology with New World machinery, this weapon fires a microscopic metal slug at 99.9% the speed of light. The kinetic energy from the slug is enough to pass right through armor and flesh."
	Type=WTRailGun
	Size=WSLarge
	MaxAmmo=100
	MaxClip=100
	Ammo=100
	AmmoPerShot=0
	Clip=100
	BaseDamage=750
	Cost=0
}