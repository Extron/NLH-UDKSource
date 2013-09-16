/*******************************************************************************
	AT_ShockShort

	Creation date: 09/09/2013 17:01
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * The ability tree for Short Range Shock.
 */
class AT_ShockShort extends AbilityTree;

defaultproperties
{
	Abilities[0]=class'Arena.Ab_ShockShort'
	Abilities[1]=class'Arena.Ab_ShotsOfHaste'
	Abilities[2]=class'Arena.Ab_ThunderRush'
	Abilities[3]=class'Arena.Ab_FlashOfLightning'
	Abilities[4]=None
	Abilities[5]=class'Arena.Ab_TheSoundOfThunder'
	Abilities[6]=None
	
	TreeName="Short-Range Shock"
}