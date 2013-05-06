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