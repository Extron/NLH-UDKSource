/*******************************************************************************
	ShockDamage

	Creation date: 24/06/2012 17:50
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Dmg_Shock extends ElementDamageType;

defaultproperties
{
	ActionString="Shocked"
	DisplayColor=0x0BB5FF
	Points=1
	
	EntityEffects[0]=class'Arena.EE_Charged'
	EntityEffects[1]=class'Arena.SE_Electrocuted'
}