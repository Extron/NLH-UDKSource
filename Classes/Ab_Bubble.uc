/*******************************************************************************
	Ab_Bubble
	
	Creation date: 28/01/2013 13:30
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Bubble extends ArenaAbility;

/** 
 * The shield that the ability generates. 
 */
var Ab_BubbleShield Shield;

/**
 * The class of the shield to generate.
 */
var class<Ab_BubbleShield> ShieldClass;


simulated function CustomFire()
{
	if (!IsHolding)
	{
		`log("Spawning shield");
		Shield = spawn(ShieldClass, Owner);
	}
}

defaultproperties
{
	// Allows for actor creation
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=20
	EnergyCost=200
	AbilityName="Bubble"
	
	CanHold=false
	IsPassive=false
	CanCharge=false
	
	ShieldClass=class'Ab_BubbleShield'
}