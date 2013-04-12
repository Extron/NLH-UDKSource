/*******************************************************************************
	Wp_OrbGun

	Creation date: 09/11/2012 10:18
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_OrbGun extends ArenaWeapon;

simulated function EmitIHBeam(vector hitLocation)
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		GetMuzzleSocketLocRot(l, r);		
		
		`log("Hit lotation:" @ hitLocation @ "Source" @ l);
		
		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, l);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', hitLocation);
		IHBeam.SetVectorParameter('SourceLocation', l);
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
		//AttachComponent(IHBeam);
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
	
	Mode=FMSemiAuto
	CycleTime=0.25
	BurstCount=3
	
	FireSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue'
	IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.PhotonBeam'
	
	Type=WTHardLightRifle
	Size=WSSmall
	MaxAmmo=300
	MaxClip=30
	Ammo=120
	Clip=30
	
	BaseDamage=100
}
