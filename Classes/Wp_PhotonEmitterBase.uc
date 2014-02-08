/*******************************************************************************
	Wp_PhotonEmitterBase

	Creation date: 02/11/2012 09:58
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_PhotonEmitterBase extends ArenaWeaponBase;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'PhotonEmitter.Meshes.PhotonEmitterBase'
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=6
		Values[WSVStability]=0.25
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
		Values[WSVAccuracy]=0.75
	End Object
	
	DefaultComponents[WCStock]=class'Arena.Wp_S_CheapStock'
	DefaultComponents[WCBarrel]=class'Arena.Wp_B_BasicRifleBarrel'
	DefaultComponents[WCMuzzle]=class'Arena.Wp_M_NoMuzzle'
	DefaultComponents[WCOptics]=class'Arena.Wp_O_NoOptics'
	DefaultComponents[WCUnderAttachment]=class'Arena.Wp_UA_NoUnderAttachment'
	DefaultComponents[WCSideAttachment]=class'Arena.Wp_SA_NoSideAttachment'
	
	WeaponFireTypes[0]=EWFT_InstantHit
	InstantHitDamageTypes[0]=class'Arena.Dmg_LightBeam'
	InstantHitMomentum[0]=500
	FireModes[0]=FMSemiAuto
	CycleTime=0.15
	BurstCount=3
	
	FireSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue'
	IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.PhotonBeam'
	
	ViewOffset=(X=45, Y=10, Z=-22);
	BaseName="Photon Emitter Base"
	BaseDescription="An advanced weapon from the Old World, a photon emitter emits a coherent beam of light with enough energy to damage organics.  Running off of batteries, these seemingly fragile weapons are surprisingly durable."
	Type=WTHardLightRifle
	Size=WSRegular
	MaxAmmo=300
	MaxClip=30
	Ammo=120
	Clip=30
	BaseDamage=200
	Cost=50
}