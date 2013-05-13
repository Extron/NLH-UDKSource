/*******************************************************************************
	ArenaHUD

	Creation date: 28/06/2012 20:52
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaHUD extends UDKHUD;

/**
 * A reference to the movie to use for the HUD.
 */
var GFx_BasicHUD HUDMovie;

/**
 * A reference to the movie to use for the pause screen.
 */
var GFx_PauseMenu PauseMenu;

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
	`log("ShowMenu called.");
	TogglePauseMenu();
}

function TogglePauseMenu()
{
    if (PauseMenu != none && PauseMenu.bMovieIsOpen)
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
            PauseMenu.MovieInfo = SwfMovie'ArenaUI.PauseMenu';
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

event PostRender()
{
	super.PostRender();

	if (HUDMovie != none)
		HUDMovie.UpdateHUD(0);
}

defaultproperties
{
	HUDClass=class'GFx_BasicHUD'
	RebootTime=5
}