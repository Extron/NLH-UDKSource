/*******************************************************************************
	ADT_FlashOfLightning

	Creation date: 21/04/2013 20:00
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * The damage type used for the Flash of Lightning ability.  Gives Electroguted and Flashed effects.
 */
class ADT_FlashOfLightning extends Dmg_Shock;

defaultproperties
{
	EntityEffects[2]=class'Arena.SE_Flash'
}