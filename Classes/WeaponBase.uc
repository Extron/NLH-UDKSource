/*******************************************************************************
	WeaponBase

	Creation date: 24/06/2012 18:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponBase extends ArenaWeapon;

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
var string WeaponBaseName;

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);
	Stock.AttachToBase(Self, StockSock);
	Barrel.AttachToBase(Self, BarrelSock);
	Optics.AttachToBase(Self, OpticsSock);
}

/*
 * Gets the total weight of the weapon.
 *
 * @return Returns the weapon's weight.
 */
function float GetWeight()
{
	return Stats.Values[WSVWeight];
}

function vector GetOpticsOffset()
{
	return Optics.OpticsOffset;
}

function AttachStock(Wp_Stock s)
{
	if (s.CanAttachToBase(self))
	{
		Stock = s;
		Energy -= s.EnergyCost;
	}
}

function AttachBarrel(Wp_Barrel b)
{
	if (b.CanAttachToBase(self))
	{
		Barrel = b;
		Energy -= b.EnergyCost;
	}
}

function AttachMuzzle(Wp_Muzzle m)
{
	if (m.CanAttachToBase(self))
	{
		Muzzle = m;
		Energy -= m.EnergyCost;
	}
}

function AttachOptics(Wp_Optics o)
{
	if (o.CanAttachToBase(self))
	{
		Optics = o;
		Energy -= o.EnergyCost;
	}
}

function AttachSide(Wp_SideAttachment s)
{
	if (s.CanAttachToBase(self))
	{
		Side = s;
		Energy -= s.EnergyCost;
	}
}

function AttachUnder(Wp_UnderAttachment u)
{
	if (u.CanAttachToBase(self))
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