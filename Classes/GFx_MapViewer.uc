/*******************************************************************************
	GFx_MapViewer

	Creation date: 27/06/2013 15:52
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_MapViewer extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{
	RenderTexture = TextureRenderTarget2D'ArenaUI.Textures.MapViewerGFxTarget';
	
	return super.Start(StartPaused);
}

function SetTitle(string ttl)
{
	ActionScriptVoid("_root.SetTitle");
}

function SetDescription(string desc)
{
	ActionScriptVoid("_root.SetDescription");
}

function SetImageSource(string src)
{
	ActionScriptVoid("_root.SetImageSource");
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.SBBMapViewer'
}