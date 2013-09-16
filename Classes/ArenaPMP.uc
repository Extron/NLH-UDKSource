/*******************************************************************************
	ArenaPMP

	Creation date: 26/05/2013 12:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPMP extends PhysicalMaterialPropertyBase
	dependson(ArenaWeapon);

/**
 * This allows a material to be given certain properties that dictate how it interacts with various effects and abilities in-game.
 */
var(Properties) array<string> MaterialProperties;

/**
 * This dictates what kind of material this is, such as wood, metal, dirt, etc.
 */
var(Properties) string MaterialType;

/**
 * This is the default decal that is used on the material if no other material can be specified.
 */
var(HitEffects) MaterialInterface DefaultDecal;

/**
 * This is the decal used when a bullet hits the material.
 */
var(HitEffects) MaterialInterface BulletDecal;

/**
 * This is the decal used when a photon beam hits the material.
 */
var(HitEffects) MaterialInterface PhotonDecal;

/**
 * This is the decal used when a plasma bolt hits the material.
 */
var(HitEffects) MaterialInterface PlasmaDecal;

/**
 * The default particle system to use when something hits the material if no other particle system can be specified.
 */
var(HitEffects) ParticleSystem DefaultHitPS;

/**
 * The particle system to use when a bullet hits the material.
 */
var(HitEffects) ParticleSystem BulletHitPS;

/**
 * The particle system to use when a photon beam hits the material.
 */
var(HitEffects) ParticleSystem PhotonHitPS;

/**
 * The particle system to use when a plasma bolt hits the material.
 */
var(HitEffects) ParticleSystem PlasmaHitPS;

/**
 * The particle system to use when something hits the material when it is wet.
 */
var(HitEffects) ParticleSystem RainHitPS;

/**
 * The particle system to use when something hits the material when it has snow on it.
 */
var(HitEffects) ParticleSystem SnowHitPS;

/**
 * Sometimes, a projectile will come with its own particle system for when it hits something.  This allows
 * the material to specify if that projectile is allowed to use its own particle system as well as the ones listed here.
 */
var(HitEffects) bool AllowOtherParticleSystem;

/**
 * The sound cue to use for playing footstep sounds on this material.
 */
var (Audio) SoundCue Footsteps;

/**
 * The sound cue to use for playing footstep sounds on this material when it is covered in snow.
 */
var (Audio) SoundCue SnowFootsteps;

/**
 * The sound cue to use for playing footstep sounds on this material when it is covered in rain.
 */
var (Audio) SoundCue RainFootsteps;


simulated function ParticleSystem GetHitParticleSystem(ArenaWeapon weapon)
{
	switch (weapon.Type)
	{
	case WTRifle:
	case WTShotgun:
		return BulletHitPS;
		
	case WTHardLightRifle:
		return PhotonHitPS;
	
	case WTPlasmaRifle:
		return PlasmaHitPS;
	}
	
	return DefaultHitPS;
}

simulated function MaterialInterface GetHitDecal(ArenaWeapon weapon)
{
	switch (weapon.Type)
	{
	case WTRifle:
	case WTShotgun:
		return BulletDecal;
		
	case WTHardLightRifle:
		return PhotonDecal;
	
	case WTPlasmaRifle:
		return PlasmaDecal;
	}
	
	return DefaultDecal;
}

simulated function bool HasProperty(string property)
{
	return MaterialProperties.Find(property) > -1;
}

simulated function bool HasProperties(array<string> properties)
{
	local int i;
	
	for (i = 0; i < properties.Length; i++)
	{
		if (!HasProperty(properties[i]))
			return false;
	}
	
	return true;
}