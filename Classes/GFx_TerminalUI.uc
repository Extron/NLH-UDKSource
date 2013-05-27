/*******************************************************************************
	GFx_TerminalUI

	Creation date: 18/05/2013 00:05
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_TerminalUI extends GFxMoviePlayer;

var GFxObject Status, Body;

function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
	
	Advance(0);
	
	Body = GetVariableObject("_root.terminal_body");
	Status = GetVariableObject("_root.status");
	
	return true;
}

function BeginHack()
{
	Body.GotoAndPlay("accessing");
	Status.GotoAndPlay("accessing");
}

function EndHack()
{	
	Body.GotoAndPlay("hacked");
	Status.GotoAndPlay("hacked");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.TerminalUI'
	bAllowInput=false
	bAllowFocus=false
	bAutoPlay=true
}