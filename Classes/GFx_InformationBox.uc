/*******************************************************************************
	GFx_InformationBox

	Creation date: 28/06/2014 13:18
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class GFx_InformationBox extends GFxMoviePlayer;

var InformationBoxDisplay Parent;

var GFxObject DataObject;

delegate OnBack();

function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
	
	Advance(0);
	
	DataObject = CreateObject("Object");
	
	return true;
}

function SetTitle(string title)
{
	ActionScriptVoid("_root.SetTitle");
}

function SetSubtitle(string subtitle)
{
	ActionScriptVoid("_root.SetSubtitle");
}

function PopulateInformation(string layout, GFxObject data)
{
	ActionScriptVoid("_root.PopulateInformation");
}

function Highlight()
{
	ActionScriptVoid("_root.Highlight");
}

function DeHighlight()
{
	ActionScriptVoid("_root.DeHighlight");
}

function Activate()
{
	ActionScriptVoid("_root.Activate");
}

function Deactivate()
{
	ActionScriptVoid("_root.Deactivate");
}

function SetCursorLocation(float x, float y)
{
	ActionScriptVoid("_root.SetCursorLocation");
}

function ClickMouse()
{
	ActionScriptVoid("_root.ClickMouse");
}

function MouseDown()
{
	ActionScriptVoid("_root.MouseDown");
}

function MouseUp()
{
	ActionScriptVoid("_root.MouseUp");
}

function InfoBoxBack()
{
	OnBack();
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.InformationBox'
	RenderTextureMode=RTM_AlphaComposite
	bAllowInput=true
	bAllowFocus=true
	bAutoPlay=true
}