/*******************************************************************************
	AT_Sand

	Creation date: 09/09/2013 17:38
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AT_Sand extends AbilityTree;

defaultproperties
{
	Abilities[0]=class'Arena.Ab_Sand'
	Abilities[1]=class'Arena.Ab_DustCloud'
	Abilities[2]=None
	Abilities[3]=class'Arena.Ab_Sandstorm'
	Abilities[4]=None
	Abilities[5]=None
	Abilities[6]=None
	
	TreeName="Sand"
}