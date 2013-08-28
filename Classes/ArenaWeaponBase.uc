/*******************************************************************************
	ArenaWeaponBase

	Creation date: 24/06/2012 18:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaWeaponBase extends ArenaWeapon;

enum WeaponComponent
{
	WCStock,
	WCBarrel,
	WCMuzzle,
	WCOptics,
	WCUnderAttachment,
	WCSideAttachment
};

/**
 * A list of all bases that exist in the game.
 */
var array<class<ArenaWeaponBase> > Subclasses;

/**
 * The allowed fire mode types for the base.
 */
var array<FireMode> AllowedFireModes;

/**
 * The default components that the weapon will be created with.
 */
var array<class<ArenaWeaponComponent> > DefaultComponents;

/**
 * The weapon components attached to the weapon.
 */
var array<ArenaWeaponComponent> WeaponComponents;

/**
 * The sockets to attach the weapon components to.
 */
var array<name> Sockets;

/* The maximum amount of energy that the base supports. */
var float EnergyMax;

/* The name of the base of the weapon. */
var string BaseName;

/**
 * A short description of the base.
 */
var string BaseDescription;

/**
 * The cost of the weapon base, in tokens.
 */
var int Cost;


simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);

	WeaponComponents[WCStock].AttachToBase(self, Sockets[WCStock]);
	WeaponComponents[WCBarrel].AttachToBase(self, Sockets[WCBarrel]);
	WeaponComponents[WCMuzzle].AttachToBase(self, Sockets[WCMuzzle]);
	WeaponComponents[WCOptics].AttachToBase(self, Sockets[WCOptics]);
	WeaponComponents[WCUnderAttachment].AttachToBase(self, Sockets[WCUnderAttachment]);
	WeaponComponents[WCSideAttachment].AttachToBase(self, Sockets[WCSideAttachment]);
}

function AttachWeapon(LightEnvironmentComponent lightEnv)
{
	super.AttachWeapon(lightEnv);

	WeaponComponents[WCStock].AttachToBaseSpecial(self, Sockets[WCStock], lightEnv);
	WeaponComponents[WCBarrel].AttachToBaseSpecial(self, Sockets[WCBarrel], lightEnv);
	WeaponComponents[WCMuzzle].AttachToBaseSpecial(self, Sockets[WCMuzzle], lightEnv);
	WeaponComponents[WCOptics].AttachToBaseSpecial(self, Sockets[WCOptics], lightEnv);
	WeaponComponents[WCUnderAttachment].AttachToBaseSpecial(self, Sockets[WCUnderAttachment], lightEnv);
	WeaponComponents[WCSideAttachment].AttachToBaseSpecial(self, Sockets[WCSideAttachment], lightEnv);
}

simulated function Destroyed()
{
	local ArenaWeaponComponent iter;
	
	foreach WeaponComponents(iter)
	{
		if (iter != None)
			iter.Destroy();
	}
}

simulated function ToggleComponent(int component)
{
	WeaponComponents[component].Toggle();
}

simulated function GetMuzzleSocketLocRot(out vector l, out rotator r)
{
	super.GetMuzzleSocketLocRot(l, r);
	
	if (!(WeaponComponents[WCMuzzle] != None && Wp_M_NoMuzzle(WeaponComponents[WCMuzzle]) != None))
	{
		if (SkeletalMeshComponent(WeaponComponents[WCBarrel].Mesh).GetSocketByName(Sockets[WCMuzzle]) != None)
			SkeletalMeshComponent(WeaponComponents[WCBarrel].Mesh).GetSocketWorldLocationAndRotation(Sockets[WCMuzzle], l, r, 0);
	}
	else
	{
		if (SkeletalMeshComponent(WeaponComponents[WCMuzzle].Mesh).GetSocketByName(Sockets[WCMuzzle]) != None)
			SkeletalMeshComponent(WeaponComponents[WCMuzzle].Mesh).GetSocketWorldLocationAndRotation(Sockets[WCMuzzle], l, r, 0);
	}
}
	
simulated function AttachToMuzzleSocket(ActorComponent component)
{
	if (WeaponComponents[WCMuzzle] == None || Wp_M_NoMuzzle(WeaponComponents[WCMuzzle]) != None)
		SkeletalMeshComponent(WeaponComponents[WCBarrel].Mesh).AttachComponentToSocket(component, Sockets[WCMuzzle]);
	else
		SkeletalMeshComponent(WeaponComponents[WCMuzzle].Mesh).AttachComponentToSocket(component, Sockets[WCMuzzle]);
}

simulated function ParticleSystem GetMuzzeFlashParticleTemplate()
{
	if (Wp_Muzzle(WeaponComponents[WCMuzzle]).OverrideDefaultMuzzleFlash())
		return Wp_Muzzle(WeaponComponents[WCMuzzle]).MuzzleFlashTemplate;
	else
		return Wp_Barrel(WeaponComponents[WCBarrel]).MuzzleFlashTemplate;
}

simulated function class<UDKExplosionLight> GetMuzzleFlashLightClass()
{
	if (Wp_Muzzle(WeaponComponents[WCMuzzle]).OverrideDefaultMuzzleFlash())
		return Wp_Muzzle(WeaponComponents[WCMuzzle]).MFLClass;
	else
		return Wp_Barrel(WeaponComponents[WCBarrel]).MFLClass;
}

simulated function SoundCue GetFireSound()
{
	if (Wp_Muzzle(WeaponComponents[WCMuzzle]).OverrideDefaultFireSound())
		return Wp_Muzzle(WeaponComponents[WCMuzzle]).FireSound;
	else
		return FireSound;
}

simulated function GetGripSocketLocRot(out vector l, out rotator r)
{
	super.GetGripSocketLocRot(l, r);
	
	if (SkeletalMeshComponent(WeaponComponents[WCBarrel].Mesh).GetSocketByName('GripSocket') != None)
	{
		SkeletalMeshComponent(WeaponComponents[WCBarrel].Mesh).GetSocketWorldLocationAndRotation('GripSocket', l, r, 0);
	}
}

/**
 * Determines if the weapon has any type of optics that allow aiming down sights.
 */
simulated function bool CanADS()
{
	return WeaponComponents[WCOptics] != None && Wp_O_NoOptics(WeaponComponents[WCOptics]) == None;
}

simulated function bool OnlyAlterWeaponFOV()
{
	return Wp_Optics(WeaponComponents[WCOptics]).OnlyZoomWeapon;
}

/**
 * Allows weapon optics to modify things like depth of field when the player aims down sights.
 */
simulated function BlurADS(UberPostProcessEffect effect)
{
	Wp_Optics(WeaponComponents[WCOptics]).BlurADS(effect);
}

/*
 * Gets the total weight of the weapon.
 *
 * @return Returns the weapon's weight.
 */
function float GetWeight()
{
	local ArenaWeaponComponent iter;
	local float weight;
	
	foreach WeaponComponents(iter)
	{
		if (iter != None)
			weight += iter.Weight;
	}
	
	return Stats.Values[WSVWeight] + weight;
}

function float GetEnergyUsed()
{
	local ArenaWeaponComponent iter;
	local float energy;
	
	foreach WeaponComponents(iter)
	{
		if (iter != None)
			energy += iter.EnergyCost;
	}
		
	return energy;
}

function vector GetOpticsOffset(ArenaPawn holder)
{	
	local vector t;
	
	t.Z = holder.EyeHeight;
	t = t + holder.Location;
	
	return Wp_Optics(WeaponComponents[WCOptics]).GetOpticsOffset(t, Rotation);
}

function float GetZoomLevel()
{
	return Stats.Values[WSVZoom];
}

simulated function HideWeapon(bool hidden)
{	
	local ArenaWeaponComponent iter;
	
	super.HideWeapon(hidden);

	foreach WeaponComponents(iter)
	{
		if (iter != None)
			iter.Mesh.SetHidden(hidden);
	}
}

simulated function SetWeaponFOV(float angle)
{
	local ArenaWeaponComponent iter;
	
	super.SetWeaponFOV(angle);

	foreach WeaponComponents(iter)
	{
		if (iter != None)
			UDKSkeletalMeshComponent(iter.Mesh).SetFOV(angle);
	}
}


function AttachStock(Wp_Stock s)
{
	if (s.CanAttachToBase(Self))
		WeaponComponents[WCStock] = s;
}

function AttachBarrel(Wp_Barrel b)
{
	if (b.CanAttachToBase(Self))
		WeaponComponents[WCBarrel] = b;
}

function AttachMuzzle(Wp_Muzzle m)
{
	if (m.CanAttachToBase(Self))
		WeaponComponents[WCMuzzle] = m;
}

function AttachOptics(Wp_Optics o)
{
	if (o.CanAttachToBase(Self) && CanEquipOptics(o))
		WeaponComponents[WCOptics] = o;
}

function AttachSide(Wp_SideAttachment s)
{
	if (s.CanAttachToBase(Self))
		WeaponComponents[WCSideAttachment] = s;
}

function AttachUnder(Wp_UnderAttachment u)
{
	if (u.CanAttachToBase(Self))
		WeaponComponents[WCUnderAttachment] = u;
}

/**
 * Some weapon bases may not support stocks.  This function can be overridden to allow weapons to specify which stocks they support.
 */
function bool CanEquipStock(Wp_Stock stock)
{
	return true;
}

/*
 * Some weapon bases may not support optics.  This allows weapons to specify which ones they support.
 */
function bool CanEquipOptics(Wp_Optics optics)
{
	return true;
}

/*
 * Some weapon bases may not support certain barrels.  This allows weapons to specify which ones they support.
 */
function bool CanEquipBarrel(Wp_Barrel barrel)
{
	return true;
}


defaultproperties
{
	Subclasses[0]=class'Arena.Wp_BasicRifleBase'
	Subclasses[1]=class'Arena.Wp_PhotonEmitterBase'
	
	WeaponComponents[WCStock]=None
	WeaponComponents[WCBarrel]=None
	WeaponComponents[WCMuzzle]=None
	WeaponComponents[WCOptics]=None
	WeaponComponents[WCUnderAttachment]=None
	WeaponComponents[WCSideAttachment]=None
	
	Sockets[WCStock]=StockSocket
	Sockets[WCBarrel]=BarrelSocket
	Sockets[WCMuzzle]=MuzzleSocket
	Sockets[WCOptics]=OpticsSocket
	Sockets[WCUnderAttachment]=UnderSocket
	Sockets[WCSideAttachment]=SideSocket
}