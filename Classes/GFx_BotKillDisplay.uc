/*******************************************************************************
	GFx_BotKillDisplay

	Creation date: 22/06/2013 22:25
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_BotKillDisplay extends GFxMoviePlayer;

function SetDisplay(string desc, float pointValue, int tokenValue)
{
	ActionScriptVoid("_root.SetDisplay");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.BotKillDisplay'
	bAllowInput=false
	bAllowFocus=false
	bAutoPlay=true
}