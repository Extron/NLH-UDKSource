/*******************************************************************************
	MenuHUD

	Creation date: 25/06/2013 16:06
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class MenuHUD extends UDKHUD;

var GFx_Menu Menu;

event Tick(float dt)
{
	super.Tick(dt);
		
	if (Menu != None && Menu.bMovieIsOpen)
		Menu.Update(dt);
}

event PostRender()
{
	super.PostRender();
	
	if (Menu != None && Menu.bMovieIsOpen)
		Menu.PostRender();
}