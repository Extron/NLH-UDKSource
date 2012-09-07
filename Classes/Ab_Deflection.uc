/*******************************************************************************
	Ab_Deflection

	Creation date: 04/09/2012 12:19
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Deflection extends ArenaAbility;

/** The shield that the ability generates. */
var Ab_DeflectionShield Shield;

simulated function StopFire(byte FireModeNum)
{
	if (Shield != None)
	{
		`log("Destroying shield");
		Shield.Destroy();
	}
		
	super.StopFire(FireModeNum);
}

simulated function FireAmmunition()
{
	if (!IsHolding)
	{
		`log("Spawning shield");
		Shield = spawn(class'Ab_DeflectionShield', Owner);
	}
	
	super.FireAmmunition();
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitMomentum(0)=+0.0
	
	FireInterval[0]=0
	InstantHitDamage(0)=0
	WeaponRange=0
	CoolDown=0
	EnergyCost=50
	AbilityName="Deflection"
	
	CanHold=true
	IsPassive=false
	CanCharge=false
}
