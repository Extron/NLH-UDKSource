/*******************************************************************************
	Dmg_Water

	Creation date: 25/08/2014 17:56
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Dmg_Water extends ElementDamageType;

defaultproperties
{
	ActionString="Doused"
	DisplayColor=0x0BB5FF
	Points=1
	
	EntityEffects[0]=class'Arena.EE_Wet'
	EntityEffects[1]=class'Arena.SE_Wet'
}