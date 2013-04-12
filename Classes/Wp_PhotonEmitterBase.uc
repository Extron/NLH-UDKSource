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
		//SkeletalMesh=SkeletalMesh'BasicRifleBase.Mesh.BasicRifleBaseMesh_1P'
		Rotation=(Yaw=16384)
		FOV=85.0
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=4
		Values[WSVStability]=0.25
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
		Values[WSVAccuracy]=5.0
	End Object
	
	WeaponFireTypes[0]=EWFT_InstantHit
	InstantHitDamageTypes[0]=class'Arena.Dmg_LightBeam'
	InstantHitMomentum[0]=500
	Mode=FMSemiAuto
	CycleTime=0.15
	BurstCount=3
	
	FireSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue'
	IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.PhotonBeam'
	
	ViewOffset=(X=45, Y=10, Z=-22);
	ArenaWeaponBaseName="Photon Emitter Base"
	Energy=0
	Type=WTHardLightRifle
	Size=WSRegular
	MaxAmmo=300
	MaxClip=30
	Ammo=120
	Clip=30
	BaseDamage=200
}