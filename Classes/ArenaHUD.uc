/*******************************************************************************
	ArenaHUD

	Creation date: 28/06/2012 20:52
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaHUD extends UDKHUD;



var array<string> AlertQueue;

var array<float> AlertTimers;


/**
 * A reference to the movie to use for the HUD.
 */
var GFx_BasicHUD HUDMovie;

/**
 * A reference to the movie to use for the pause screen.
 */
var GFx_PauseMenu PauseMenu;

/**
 * The currently overlayed menu.  Can be used to display any menu system needed in-game.
 */
var GFx_Menu OverlayMenu;

/**
 * The class of the HUD to create.
 */
var class<GFx_BasicHUD> HUDClass;

/**
 * The time it takes for the HUD to reboot.
 */
var float RebootTime;

singular event Destroyed()
{
	if (HUDMovie != None)
	{
		HUDMovie.Close(true);
		HUDMovie = None;
	}

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	HUDMovie = new HUDClass;
	HUDMovie.SetTimingMode(TM_Real);
	HUDMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HUDMovie.LocalPlayerOwnerIndex]);
}

function SetVisible(bool visible)
{
	if (!visible)
		HUDMovie.HideAllComponents();
	else
		HUDMovie.UnhideAllComponents();
}

function CloseOtherMenus()
{
}

exec function ShowMenu()
{
	TogglePauseMenu();
}

function TogglePauseMenu()
{
	if (OverlayMenu != None && OverlayMenu.bMovieIsOpen)
	{
		if (!OverlayMenu.InterceptEscape())
			OverlayMenu.PlayCloseAnimation();
	}
    else if (PauseMenu != none && PauseMenu.bMovieIsOpen)
	{
		PauseMenu.PlayCloseAnimation();
	}
	else
    {
		CloseOtherMenus();

        PlayerOwner.SetPause(True);

        if (PauseMenu == None)
        {
	        PauseMenu = new class'GFx_PauseMenu';
            PauseMenu.bEnableGammaCorrection = FALSE;
			PauseMenu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
            PauseMenu.SetTimingMode(TM_Real);
        }

		SetVisible(false);
        PauseMenu.Start();
        PauseMenu.PlayOpenAnimation();
    }
}

function ClosePauseMenu()
{
	PlayerOwner.SetPause(False);
	PauseMenu.Close(false);
	SetVisible(true);
}

function RebootHUD()
{
	HUDMovie.HideAllComponents();
	
	SetTimer(RebootTime, false, 'HUDRebooted');
}

function HUDRebooted()
{
	HUDMovie.UnhideAllComponents();
}

function int GetLocalPlayerOwnerIndex()
{
	return HudMovie.LocalPlayerOwnerIndex;
}

event Tick(float dt)
{
	super.Tick(dt);
	
	if (HUDMovie != none)
		HUDMovie.UpdateHUD(dt);
		
	if (OverlayMenu != None && OverlayMenu.bMovieIsOpen)
		OverlayMenu.Update(dt);
}

event PostRender()
{
	super.PostRender();
	
	if (OverlayMenu != None && OverlayMenu.bMovieIsOpen)
		OverlayMenu.PostRender();
}

function DisplayOverlayMenu(class<GFx_Menu> overlayClass, optional bool pause = true)
{
	CloseOtherMenus();

	PlayerOwner.SetPause(pause);

	OverlayMenu = new overlayClass;
	OverlayMenu.bEnableGammaCorrection = FALSE;
	OverlayMenu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
	OverlayMenu.SetTimingMode(TM_Real);

	SetVisible(false);
	OverlayMenu.Start();
	OverlayMenu.PlayOpenAnimation();
}

function CloseOverlayMenu()
{
	PlayerOwner.SetPause(False);
	OverlayMenu.Close(false);
	SetVisible(true);
}

/**
 * Queues up an alert to be sent to the HUD, with a specified time displayed.
 */
function QueueAlert(string alert, float time)
{
	if (AlertQueue.Length == 0)
	{
		SetTimer(time, false, 'RemoveAlert');
		HUDMovie.AlertMessageBox.SendAlert(alert);
	}
	
	AlertQueue.AddItem(alert);
	AlertTimers.AddItem(time);
}

function RemoveAlert()
{
	AlertQueue.Remove(0, 1);
	AlertTimers.Remove(0, 1);
	
	if (AlertQueue.Length > 0)
	{
		HUDMovie.AlertMessageBox.SendAlert(AlertQueue[0]);
		SetTimer(AlertTimers[0], false, 'RemoveAlert');
	}
	else
	{
		HUDMovie.AlertMessageBox.SendAlert("");
		HUDMovie.QueuedAlerts = false;
	}
}

defaultproperties
{
	HUDClass=class'GFx_BasicHUD'
	RebootTime=5
	bAlwaysTick=true
}