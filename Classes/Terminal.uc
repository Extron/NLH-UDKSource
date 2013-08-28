/*******************************************************************************
	Terminal

	Creation date: 18/03/2013 11:29
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A hackable terminal to use in Bot Battle.
 */
class Terminal extends InteractiveObject
	placeable;

	
/**
 * The amount of time required to hack the terminal.
 */
var(Terminal) float HackTime;

/**
 * Indicates that the termila can hack itself, and the player can just initialize it.  This is
 * opposed to requiring the player to "hold key" or play a minigame.
 */
var(Termial) bool AutoHack;

/**
 * A light component to attach to the terminal to simulate monitor glow.
 */
var(Terminal) LightComponent Light;

/**
 * The render target to use to display the terminal's UI.
 */
var TextureRenderTarget2D RenderTarget;

/**
 * The terminal UI to display on the terminal screen.
 */
var GFx_TerminalUI TerminalUI;

/**
 * The class of the terminal UI to use.
 */
var class<GFx_TerminalUI> TerminalUIClass;

/**
 * Contains the amount of time currently in the hack.
 */
var float Counter;

/**
 * Indicates that the terminal is currently being hacked.
 */
var bool Hacking;



simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	TerminalUI = new TerminalUIClass;
	
	if (TerminalUI != None && RenderTarget != None)
	{
		TerminalUI.RenderTexture = RenderTarget;
		TerminalUI.SetTimingMode(TM_Real);
		TerminalUI.Init();
	}
}


simulated function Tick(float dt)
{
	super.Tick(dt);
	
	if (Hacking)
	{
		Counter += dt;
		
		if (Counter >= HackTime)
		{
			Hacking = false;
			TriggerEventClass(class'Arena.SeqEvent_TerminalHacked', self, 0);
			
			if (TerminalUI != None)
				TerminalUI.EndHack();
		}
	}
}

/**
 * This is called when the object is being interacted with.
 */
simulated function InteractWith(Pawn user)
{
	super.InteractWith(user);
	
	if (AutoHack && !Hacking)
	{
		Hacking = true;
		
		if (TerminalUI != None)
			TerminalUI.BeginHack();
	}
}

defaultproperties
{
	SupportedEvents.Add(class'Arena.SeqEvent_TerminalHacked')
	RenderTarget=TextureRenderTarget2D'ArenaObjects.Textures.TerminalGFxTarget'
	
	TerminalUIClass=class'GFx_TerminalUI'
	
	Begin Object Class=SpotLightComponent Name=LC
		Rotation=(Yaw=16384)
		Translation=(Z=64)
		Brightness=1
		Radius=512
		LightColor=(R=255,G=0,B=0, A=255)
	End Object
	Light=LC
	Components.Add(LC)
	
	bCollideActors=true
	bBlockActors=true
	
	InteractionMessage="hack terminal."
	InteractionRadius=200
	HackTime=5
	AutoHack=true
}