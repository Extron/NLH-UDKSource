/*******************************************************************************
	Wp_OrbGun

	Creation date: 09/11/2012 10:18
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_OrbGun extends ArenaWeapon;

simulated function EmitIHBeam(ImpactInfo impact)
{
	local ParticleSystemComponent beam;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		beam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, impact.StartTrace);
		beam.SetAbsolute(false, false, false);
		beam.SetVectorParameter('HitLocation', impact.HitLocation);
		beam.SetVectorParameter('SourceLocation', impact.StartTrace);
		beam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		beam.bUpdateComponentInTick = true;
	}
}
/**
 * Computes the location of the muzzle socket for the weapon.  Is designed to be overridden in subclasses.
 */
simulated function GetMuzzleSocketLocRot(out vector l, out rotator r)
{
	if (ArenaPawn(Instigator).Mesh.GetSocketByName('ArmSocket') != None)
	{
		ArenaPawn(Instigator).Mesh.GetSocketWorldLocationAndRotation('ArmSocket', l, r, 0);
	}
}

defaultproperties
{	
	Begin Object Name=NewStats
		Values[WSVAccuracy]=5.0
	End Object
	
	WeaponFireTypes[0]=EWFT_InstantHit
	InstantHitDamageTypes[0]=class'Arena.Dmg_LightBeam'
	InstantHitMomentum[0]=100.0
	
	FireModes[0]=FMSemiAuto
	Mode=0
	CycleTime=0.25
	BurstCount=3
	
	FireSound=SoundCue'PhotonEmitter.Audio.FireSC'
	IHBeamTemplate=ParticleSystem'PhotonEmitter.Particles.PhotonBeam'
	
	Type=WTHardLightRifle
	Size=WSSmall
	MaxAmmo=300
	MaxClip=30
	Ammo=120
	Clip=30
	
	IdealRange=500
	BaseDamage=50
}
