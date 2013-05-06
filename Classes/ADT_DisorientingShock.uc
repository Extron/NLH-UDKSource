/*******************************************************************************
	ADT_DisorientingShock

	Creation date: 21/04/2013 20:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ADT_DisorientingShock extends AbilityDamageType;

defaultproperties
{
	EnvironmentEffects[0]=class'Arena.EE_Charged'
	StatusEffects[0]=class'Arena.SE_Electrocuted'
	StatusEffects[1]=class'Arena.SE_Disorient'
}