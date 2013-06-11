/*******************************************************************************
	Muzzle

	Creation date: 07/07/2012 14:55
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Muzzle extends ArenaWeaponComponent;


/**
 * The muzzle flash that the barrel emits when the weapon is fired.
 */
var ParticleSystem MuzzleFlashTemplate;

/**
 * The light to use for the muzzle flash.
 */
var class<UDKExplosionLight> MFLClass;

/**
 * Muzzles can choose to override weapon firing sounds with this sound.
 */
var SoundCue FireSound;


simulated function AttachToBase(ArenaWeaponBase weapon, name socket)
{
	local Wp_Barrel barrel;
	
	barrel = Wp_Barrel(weapon.WeaponComponents[WCBarrel]);
	
	if (barrel == None)
	{
		`warn("Weapon does not have a barrel, can't attach a muzzle.");
		return;
	}
	
	if (SkeletalMeshComponent(barrel.Mesh).GetSocketByName(socket) != None)
		SetBase(barrel, , SkeletalMeshComponent(barrel.Mesh), socket);
	
	AttachComponent(Mesh);
	SetHidden(false);
	Mesh.SetLightEnvironment(ArenaPawn(weapon.Instigator).LightEnvironment);
		
	WeaponBase = weapon;
	
	weapon.Stats.Values[WSVWeight] += Weight;
	weapon.Stats.AddModifier(StatMod);
}

simulated function AttachToBaseSpecial(ArenaWeaponBase weapon, name socket, LightEnvironmentComponent lightEnv)
{
	local Wp_Barrel barrel;
	
	barrel = Wp_Barrel(weapon.WeaponComponents[WCBarrel]);
	
	if (SkeletalMeshComponent(barrel.Mesh).GetSocketByName(socket) != None)
	{		
		SetBase(barrel, , SkeletalMeshComponent(barrel.Mesh), socket);
	}
	
	AttachComponent(Mesh);
	SetHidden(false);
	Mesh.SetLightEnvironment(lightEnv);
	
	weapon.Stats.Values[WSVWeight] += Weight;
	weapon.Stats.AddModifier(StatMod);
}

simulated function bool CanAttachToBase(ArenaWeaponBase baseWeap)
{
	return super.CanAttachToBase(baseWeap) && Wp_Barrel(baseWeap.WeaponComponents[WCBarrel]).CanEquipMuzzle(self);
}

/**
 * Indicates that the muzzle's particle effect should be used over the weapon's default muzzle effect.
 */
simulated function bool OverrideDefaultMuzzleFlash()
{
	return false;
}

/**
 * Indicates that the muzzle's firing sound should override the weapon's default firing sound.
 */
simulated function bool OverrideDefaultFireSound()
{
	return false;
}

defaultproperties
{
	Subclasses[0]=class'Arena.Wp_M_NoMuzzle'
	Subclasses[1]=class'Arena.Wp_M_RifleSilencer'
}