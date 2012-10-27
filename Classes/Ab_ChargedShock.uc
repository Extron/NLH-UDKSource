/*******************************************************************************
	Ab_ChargedShock

	Creation date: 05/10/2012 22:44
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_ChargedShock extends Ab_ShockMedium;


simulated function FireAmmunition()
{
	InstantHitDamage[0] = 900 * (ChargeTime / MaxCharge) + 300 * (1 - (ChargeTime / MaxCharge));
	
	super.FireAmmunition();
}

defaultproperties
{
	AbilityName="Charged Shock"
	FireSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	
	CanCharge=true
	MaxCharge=15
	MinCharge=5
}