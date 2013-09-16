/*******************************************************************************
	AP_Specter

	Creation date: 02/04/2013 10:53
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A pawn that represents the disembodied flying camera, can be used for spectating or utility functions like 
 * menus.
 */
class AP_Specter extends ArenaPawn;

/**
 * The current menu that the player is viewing.
 */
var GFx_Menu CurrentMenu;

simulated function SetMenu(GFx_Menu menu)
{
	CurrentMenu = menu;
	
	if (MenuHUD(PlayerController(Controller).MyHUD) != None)
		MenuHUD(PlayerController(Controller).MyHUD).Menu = menu;
}

defaultproperties
{
	HasFootsteps=false
}