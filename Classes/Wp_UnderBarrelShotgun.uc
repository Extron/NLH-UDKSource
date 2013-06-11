/*******************************************************************************
	Wp_UnderBarrelShotgun

	Creation date: 10/06/2013 01:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This weapon encapsulates the under barrel shotgun, and will be used when the player toggles the under barrel attachment when the shotgun is equipped.
 */
class Wp_UnderBarrelShotgun extends ArenaWeapon;


/**
 * The parent attachment that owns the shotgun.
 */
var Wp_UA_Shotgun Attachment;

/**
 * The number of pellets to fire.
 */
var int PelletCount;

simulated function BeginFire(Byte FireModeNum)
{
	`log("Setting pending fire" @ InvManager);
	
	SetPendingFire(FireModeNum);
}

simulated function FireAmmunition()
{
	local int i;
	
	`log("Firing shotgun");
	
	if (EndedFire)
		return;
		
	if (FireModes[Mode] == FMFullAuto || (FireModes[Mode] == FMSemiAuto && BulletsFired < 1) || (FireModes[Mode] == FMBurst && BulletsFired < BurstCount) || (FireModes[Mode] == FMBoltAction && !Cycling))
	{
		FireWeapon();
	
		BulletsFired++;
		
		ConsumeAmmo(CurrentFireMode);
		
		for (i = 0; i < PelletCount; i++)
			ProjectileFire();

		NotifyWeaponFired(CurrentFireMode);
	}
}

/**
 * Computes the location of the muzzle socket for the weapon.  Is designed to be overridden in subclasses.
 */
simulated function GetMuzzleSocketLocRot(out vector l, out rotator r)
{
	if (SkeletalMeshComponent(Attachment.Mesh).GetSocketByName('MuzzleSocket') != None)
	{
		SkeletalMeshComponent(Attachment.Mesh).GetSocketWorldLocationAndRotation('MuzzleSocket', l, r, 0);
	}
}

simulated state Active
{
	/** Override BeginFire so that it will enter the firing state right away. */
	simulated function BeginFire(byte FireModeNum)
	{
		if( !bDeleteMe && Instigator != None )
		{
			Global.BeginFire(FireModeNum);

			`log("Shotgun in active state and waiting to fire." @ PendingFire(FireModeNum)  @ HasAmmo(FireModeNum));
			// in the active state, fire right away if we have the ammunition
			if( PendingFire(FireModeNum) && HasAmmo(FireModeNum) )
			{
		
				SendToFiringState(FireModeNum);
			}
		}
	}
}

defaultproperties
{	
	Begin Object Name=NewStats
		Values[WSVAccuracy]=0.15
	End Object
	
	WeaponFireTypes[0]=EWFT_Projectile
	WeaponProjectiles[0]=class'Arena.Proj_ShotgunPellet'

	FireModes[0]=FMBoltAction
	Mode=0
	CycleTime=1
	
	FireSound=SoundCue'UAShotgun.Audio.GunshotSC'
	CycleSound=SoundCue'UAShotgun.Audio.CycleSC'
	//IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.PhotonBeam'
	
	PelletCount=15
	Type=WTShotgun
	Size=WSSmall
	
	MaxAmmo=8
	Ammo=8
	MaxClip=4
	Clip=4
	BaseDamage=30
}