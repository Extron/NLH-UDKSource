/*******************************************************************************
	ShockDamage

	Creation date: 24/06/2012 17:50
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Dmg_Shock extends AbilityDamageType;

defaultproperties
{
	EnvironmentEffects[0]=class'Arena.EE_Charged'
	StatusEffects[0]=class'Arena.SE_Electrocuted'
}