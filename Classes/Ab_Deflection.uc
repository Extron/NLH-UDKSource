/*******************************************************************************
	Ab_Deflection

	Creation date: 04/09/2012 12:19
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Deflection extends ArenaAbility;

/** 
 * The shield that the ability generates. 
 */
var Ab_DeflectionShield Shield;

/**
 * The class of the shield to generate.
 */
var class<Ab_DeflectionShield> ShieldClass;


simulated function StopFire(byte FireModeNum)
{
	if (Shield != None)
	{
		`log("Destroying shield");
		Shield.Destroy();
	}
		
	super.StopFire(FireModeNum);
}

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
	WeaponFireTypes(0)=EWFT_Custom
	
	FireInterval[0]=0
	CoolDown=0
	EnergyCost=78
	AbilityName="Deflection"
	AbilityIcon="ArenaAbilities.Icons.Deflection"
	
	ShieldClass=class'Ab_DeflectionShield'
	CanHold=true
	IsPassive=false
	CanCharge=false
}
