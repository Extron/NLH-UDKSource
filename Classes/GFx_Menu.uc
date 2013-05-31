/*******************************************************************************
	GFx_Menu

	Creation date: 16/05/2013 19:10
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_Menu extends GFxMoviePlayer
	abstract;

/**
 * Indicates that the menu is being displayed as an overlay in-game.
 */
var bool InGame;


function Update(float dt);

/**
 * This function is called on menus that run on the HUD.
 */
function PostRender()
{
}

function PlayOpenAnimation()
{
}

function PlayCloseAnimation()
{
	CloseAnimCompleted();
}

function CloseAnimCompleted()
{
	if (InGame)
		ArenaHUD(GetPC().MyHUD).CloseOverlayMenu();
}

function bool InterceptEscape()
{
	return false;
}