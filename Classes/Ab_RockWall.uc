/******************************************************************************
	Ab_RockWall
	
	Creation date: 13/02/2013 14:08
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWall extends ArenaAbility;

/** 
 * The pedestal that the ability generates. 
 */
var Ab_PedestalBoulder Pedestal;

simulated function CustomFire()
{
	if (!IsHolding)
	{
		`log("Spawning rock pedestal");
		Pedestal = Spawn(class 'Arena.Ab_PedestalBoulder', Owner);
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=4
	EnergyCost=300
	AbilityName="Rock Wall"
	
	CanHold=false
	IsPassive=false
	CanCharge=false
	CollideActors=true
}