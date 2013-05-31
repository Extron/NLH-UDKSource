/*******************************************************************************
	ArenaWeaponBase

	Creation date: 24/06/2012 18:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaWeaponBase extends ArenaWeapon;

/* The components that can attach to the weapon base. */
var Wp_Stock Stock;
var Wp_Barrel Barrel;
var Wp_Muzzle Muzzle;
var Wp_Optics Optics;
var Wp_SideAttachment Side;
var Wp_UnderAttachment Under;

/* The sockets on the base that the components attach to. */
var name StockSock, BarrelSock, MuzzleSock, OpticsSock, SideSock, UnderSock;

/* The amount of energy that this base currently has.  Affects what kind of attachments can be used on it. */
var float Energy;

/* The maximum amount of energy that the base supports. */
var float EnergyMax;

/* The name of the base of the weapon. */
var string ArenaWeaponBaseName;

/**
 * A short description of the base.
 */
var string BaseDescription;

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);
	
	Stock.AttachToBase(Self, StockSock);
	Barrel.AttachToBase(Self, BarrelSock);
	Optics.AttachToBase(Self, OpticsSock);
}

function AttachWeapon(LightEnvironmentComponent lightEnv)
{
	super.AttachWeapon(lightEnv);
	
	Stock.AttachToBaseSpecial(Self, StockSock, lightEnv);
	Barrel.AttachToBaseSpecial(Self, BarrelSock, lightEnv);
	Optics.AttachToBaseSpecial(Self, OpticsSock, lightEnv);
}

simulated function Destroyed()
{
	if (Stock != None)
		Stock.Destroy();
		
	if (Barrel != None)
		Barrel.Destroy();
	
	if (Muzzle != None)
		Muzzle.Destroy();

	if (Optics != None)
		Optics.Destroy();
		
	if (Side != None)
		Side.Destroy();
		
	if (Under != None)
		Under.Destroy();
}

simulated function GetMuzzleSocketLocRot(out vector l, out rotator r)
{
	super.GetMuzzleSocketLocRot(l, r);
	
	if (SkeletalMeshComponent(Barrel.Mesh).GetSocketByName('MuzzleSocket') != None)
	{
		SkeletalMeshComponent(Barrel.Mesh).GetSocketWorldLocationAndRotation('MuzzleSocket', l, r, 0);
	}
}
	
simulated function AttachToMuzzleSocket(ActorComponent component)
{
/*
	if (Muzzle != None)
		SkeletalMeshComponent(Muzzle.Mesh).AttachComponentToSocket(component, 'MuzzleEndSocket');
	else*/	
	SkeletalMeshComponent(Barrel.Mesh).AttachComponentToSocket(component, 'MuzzleSocket');
		
	//SkeletalMeshComponent(Mesh).AttachComponentToSocket(component, BarrelSock);
}

simulated function ParticleSystem GetMuzzeFlashParticleTemplate()
{
	return Barrel.MuzzleFlashTemplate;
}

simulated function class<UDKExplosionLight> GetMuzzleFlashLightClass()
{
	return Barrel.MFLClass;
}

simulated function GetGripSocketLocRot(out vector l, out rotator r)
{
	super.GetGripSocketLocRot(l, r);
	
	if (SkeletalMeshComponent(Barrel.Mesh).GetSocketByName('GripSocket') != None)
	{
		SkeletalMeshComponent(Barrel.Mesh).GetSocketWorldLocationAndRotation('GripSocket', l, r, 0);
	}
}

/*
 * Gets the total weight of the weapon.
 *
 * @return Returns the weapon's weight.
 */
function float GetWeight()
{
	return Stats.Values[WSVWeight] + Stock.Weight + Barrel.Weight + Muzzle.Weight + Optics.Weight + Side.Weight + Under.Weight;
}

function vector GetOpticsOffset(ArenaPawn holder)
{	
	local vector t;
	
	t.Z = holder.EyeHeight;
	t = t + holder.Location;
	
	return Optics.GetOpticsOffset(t, Rotation);
}

function float GetZoomLevel()
{
	return Stats.Values[WSVZoom];
}

simulated function HideWeapon(bool hidden)
{
	super.HideWeapon(hidden);
	
	Stock.Mesh.SetHidden(hidden);	
	Barrel.Mesh.SetHidden(hidden);	
	Muzzle.Mesh.SetHidden(hidden);	
	Optics.Mesh.SetHidden(hidden);	
	Side.Mesh.SetHidden(hidden);	
	Under.Mesh.SetHidden(hidden);
}

function AttachStock(Wp_Stock s)
{
	if (s.CanAttachToBase(Self))
	{
		Stock = s;
		Energy -= s.EnergyCost;
	}
}

function AttachBarrel(Wp_Barrel b)
{
	if (b.CanAttachToBase(Self))
	{
		Barrel = b;
		Energy -= b.EnergyCost;
	}
}

function AttachMuzzle(Wp_Muzzle m)
{
	if (m.CanAttachToBase(Self))
	{
		Muzzle = m;
		Energy -= m.EnergyCost;
	}
}

function AttachOptics(Wp_Optics o)
{
	if (o.CanAttachToBase(Self))
	{
		Optics = o;
		Energy -= o.EnergyCost;
	}
}

function AttachSide(Wp_SideAttachment s)
{
	if (s.CanAttachToBase(Self))
	{
		Side = s;
		Energy -= s.EnergyCost;
	}
}

function AttachUnder(Wp_UnderAttachment u)
{
	if (u.CanAttachToBase(Self))
	{
		Under = u;
		Energy -= u.EnergyCost;
	}
}

defaultproperties
{
	StockSock=StockSocket
	BarrelSock=BarrelSocket
	OpticsSock=OpticsSocket
}