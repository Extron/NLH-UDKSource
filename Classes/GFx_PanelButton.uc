/*******************************************************************************
	GFx_PanelButton

	Creation date: 26/06/2013 11:32
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_PanelButton extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{
	`log("Starting panel button");
	
	return super.Start(StartPaused);
}

function SetLabel(string l)
{
	ActionScriptVoid("_root.SetLabel");
}

function Hover()
{
	ActionScriptVoid("_root.Hover");
}

function Press()
{
	ActionScriptVoid("_root.Press");
}

function Release()
{
	ActionScriptVoid("_root.Release");
}

function Leave()
{
	ActionScriptVoid("_root.Leave");
}

function PlayClose()
{
	ActionScriptVoid("_root.Close");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.SBBPanelButton'
}