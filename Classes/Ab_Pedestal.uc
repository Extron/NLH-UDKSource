/******************************************************************************
	Ab_Pedestal
	
	Creation date: 06/02/2013 22:57
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_Pedestal extends ArenaAbility;

/* The pedestal that the ability generates. */
var Ab_PedestalBoulder Pedestal;

/* The float that determines how far in the ground the pedestal starts */
var float StartDepth;

/**
 * The maximum range from above the ground that a character can spawn a pedestal.
 */
var float Range;


simulated function CustomFire()
{
	local vector traceLoc, traceNorm;
	
	if (!IsHolding)
	{
		if (Trace(traceLoc, traceNorm, Instigator.Location + vect(0, 0, -1) * Range, Instigator.Location) != None)
		{
			Pedestal = Spawn(class 'Arena.Ab_PedestalBoulder', None, , traceLoc + (vect(0, 0, -1) * StartDepth));
		}
	}
}

simulated function StartFire(byte FireModeNum)
{
	local vector traceLoc, traceNorm;
	
	if (Trace(traceLoc, traceNorm, Instigator.Location + vect(0, 0, -1) * Range, Instigator.Location) != None)
		super.StartFire(FireModeNum);
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=4
	EnergyCost=300
	AbilityName="Pedestal"
	
	CanHold=false
	IsPassive=false
	CanCharge=false
	StartDepth = 265.0
	Range=150
}