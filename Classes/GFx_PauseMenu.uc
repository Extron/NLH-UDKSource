/*******************************************************************************
	GFx_PauseMenu

	Creation date: 06/05/2013 15:24
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_PauseMenu extends GFxMoviePlayer;

var GFxObject Buttons, ResumeBW, ExitBW, Background;
var GFxClikWidget ResumeButton, ExitButton;

function bool Start(optional bool StartPaused = false)
{	
	super.Start(StartPaused);
			
    Advance(0);
		
	Buttons = GetVariableObject("_root.buttons");
	ResumeBW = GetVariableObject("_root.buttons.resume_button");
	ExitBW = GetVariableObject("_root.buttons.exit_button");
	Background = GetVariableObject("_root.background");

	ResumeButton = GFxClikWidget(ResumeBW.GetObject("button", class'GFxClikWidget'));
	ExitButton = GFxClikWidget(ExitBW.GetObject("button", class'GFxClikWidget'));
	
	ResumeButton.AddEventListener('CLIK_click', OnPressResumeButton);
	ExitButton.AddEventListener('CLIK_click', OnPressExitButton);

	return true;	
}

function OnPressResumeButton(GFxClikWidget.EventData ev)
{
    PlayCloseAnimation();
}

function OnPressExitButton(GFxClikWidget.EventData ev)
{
	ConsoleCommand("open Initial?Game=Arena.GI_Menus -log");
}

function PlayOpenAnimation()
{
	Buttons.GotoAndPlayI(0);
	Background.GotoAndPlayI(0);
}

function PlayCloseAnimation()
{
	Buttons.GotoAndPlayI(7);
	Background.GotoAndPlayI(7);
}

function CloseAnimCompleted()
{
	ArenaHUD(GetPC().MyHUD).ClosePauseMenu();
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.PauseMenu'
	
    bEnableGammaCorrection=FALSE
	bPauseGameWhileActive=TRUE
}