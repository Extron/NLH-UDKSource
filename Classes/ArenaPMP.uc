/*******************************************************************************
	ArenaPMP

	Creation date: 26/05/2013 12:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPMP extends PhysicalMaterialPropertyBase
	dependson(ArenaWeapon);

/**
 * Pairs a projectile with particle systems and decals.
 */
struct ProjectileEffect
{
	/**
	 * Each projectile type in the game has a unique tag.  This specifies which projectile the particle system pairs to.
	 */
	var() string ProjectileTag;
	
	/**
	 * The particle system to pair to the projectile.
	 */
	var() ParticleSystem ParticleSystem;
	
	/**
	 * The decal to use when the projectile strikes a surface.
	 */
	var() MaterialInterface Decal;
};


/**
 * This allows a material to be given certain properties that dictate how it interacts with various effects and abilities in-game.
 */
var(Properties) array<string> MaterialProperties;

/**
 * This dictates what kind of material this is, such as wood, metal, dirt, etc.
 */
var(Properties) string MaterialType;

/**
 * The effects to use when this material is struck by a projectile.
 */
var(HitEffects) array<ProjectileEffect> ProjectileEffects;

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


simulated function ParticleSystem GetProjectileParticleSystem(ArenaProjectile projectile)
{
	local int i;
	
	for (i = 1; i < ProjectileEffects.Length; i++)
	{
		if (ProjectileEffects[i].ProjectileTag == projectile.ProjectileTag)
			return ProjectileEffects[i].ParticleSystem;
	}

	if (ProjectileEffects.Length > 0 && ProjectileEffects[0].ProjectileTag == "Default")
		return ProjectileEffects[0].ParticleSystem;
	else
		return None;
}

simulated function ParticleSystem GetParticleSystem(string tag)
{
	local int i;
	
	for (i = 1; i < ProjectileEffects.Length; i++)
	{
		if (ProjectileEffects[i].ProjectileTag == tag)
			return ProjectileEffects[i].ParticleSystem;
	}

	return None;
}

simulated function MaterialInterface GetProjectileDecal(ArenaProjectile projectile)
{
	local int i;
	
	for (i = 1; i < ProjectileEffects.Length; i++)
	{
		if (ProjectileEffects[i].ProjectileTag == projectile.ProjectileTag)
			return ProjectileEffects[i].Decal;
	}

	if (ProjectileEffects.Length > 0 && ProjectileEffects[0].ProjectileTag == "Default")
		return ProjectileEffects[0].Decal;
	else
		return None;
}

simulated function MaterialInterface GetDecal(string tag)
{
	local int i;
	
	for (i = 1; i < ProjectileEffects.Length; i++)
	{
		if (ProjectileEffects[i].ProjectileTag == tag)
			return ProjectileEffects[i].Decal;
	}

	return None;
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

defaultproperties
{
	ProjectileEffects[0]=(ProjectileTag="Default")
}