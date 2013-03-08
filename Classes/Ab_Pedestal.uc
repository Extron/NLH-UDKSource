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

simulated function CustomFire()
{
	if (!IsHolding)
	{
		`log("Spawning rock pedestal");
		Pedestal = Spawn(class 'Arena.Ab_PedestalBoulder', Owner, , Instigator.Location + (vect(0, -1.5, -1) * StartDepth));
	}
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
}