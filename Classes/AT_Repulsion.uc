/*******************************************************************************
	AT_Repulsion

	Creation date: 09/09/2013 18:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AT_Repulsion extends AbilityTree;

defaultproperties
{
	Abilities[0]=class'Arena.Ab_Repulsion'
	Abilities[1]=class'Arena.Ab_Magnetism'
	Abilities[2]=None
	Abilities[3]=None
	Abilities[4]=None
	Abilities[5]=None
	Abilities[6]=None
	
	TreeName="Repulsion"
	TreeIcon="ArenaAbilities.Icons.Repulsion"
}