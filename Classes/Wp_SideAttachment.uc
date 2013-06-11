/*******************************************************************************
	SideAttachment

	Creation date: 07/07/2012 14:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_SideAttachment extends ArenaWeaponComponent;

simulated function bool CanAttachToBase(ArenaWeaponBase baseWeap)
{
	return super.CanAttachToBase(baseWeap) && Wp_Barrel(baseWeap.WeaponComponents[WCBarrel]).CanEquipSideAttachment(self);
}

simulated function AttachToBase(ArenaWeaponBase weapon, name socket)
{
	local Wp_Barrel barrel;
	
	barrel = Wp_Barrel(weapon.WeaponComponents[WCBarrel]);
	
	if (barrel == None)
	{
		`warn("Weapon does not have a barrel, can't attach a side attachment.");
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

defaultproperties
{
	Subclasses[0]=class'Wp_SA_NoSideAttachment'
	Subclasses[1]=class'Wp_SA_Flashlight'
}