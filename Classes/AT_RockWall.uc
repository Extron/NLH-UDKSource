/*******************************************************************************
	AT_RockWall

	Creation date: 09/09/2013 17:36
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AT_RockWall extends AbilityTree;

defaultproperties
{
	Abilities[0]=class'Arena.Ab_RockWall'
	Abilities[1]=class'Arena.Ab_PortableShield'
	Abilities[2]=class'Arena.Ab_StoneSlab'
	Abilities[3]=class'Arena.Ab_WallLaunch'
	Abilities[4]=None
	Abilities[5]=None
	Abilities[6]=None
	
	TreeName="Rock Wall"
}