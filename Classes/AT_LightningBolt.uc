/*******************************************************************************
	AT_LightningBolt

	Creation date: 09/09/2013 17:24
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AT_LightningBolt extends AbilityTree;

defaultproperties
{
	Abilities[0]=class'Arena.Ab_LightningBolt'
	Abilities[1]=class'Arena.Ab_Discharge'
	Abilities[2]=None
	Abilities[3]=class'Arena.Ab_LightningStorm'
	Abilities[4]=None
	Abilities[5]=None
	Abilities[6]=None
	
	TreeName="Lightning Bolt"
	TreeIcon="ArenaAbilities.Icons.LightningBolt"
}