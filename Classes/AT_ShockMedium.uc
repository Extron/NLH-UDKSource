/*******************************************************************************
	AT_ShockMedium

	Creation date: 09/09/2013 17:11
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AT_ShockMedium extends AbilityTree;

defaultproperties
{
	Abilities[0]=class'Arena.Ab_ShockMedium'
	Abilities[1]=class'Arena.Ab_ChargedShock'
	Abilities[2]=class'Arena.Ab_DisorientingShock'
	Abilities[3]=None
	Abilities[4]=None
	Abilities[5]=None
	Abilities[6]=None
	
	TreeName="Medium-Range Shock"
}