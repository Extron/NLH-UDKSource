/*******************************************************************************
	Dmg_Earthquake

	Creation date: 22/06/2013 16:44
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Dmg_Earthquake extends AbilityDamageType;

defaultproperties
{
	ActionString="Earthquaked"
	DisplayColor=0x5E2605
	Points=1
	
	EnvironmentEffects[0]=class'Arena.EE_Charged'
	StatusEffects[0]=class'Arena.SE_Electrocuted'
}