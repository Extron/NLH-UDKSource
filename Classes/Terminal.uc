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
 * Contains the amount of time currently in the hack.
 */
var float Counter;

/**
 * Indicates that the terminal is currently being hacked.
 */
var bool Hacking;


simulated function Tick(float dt)
{
	if (Hacking)
	{
		Counter += dt;
		
		if (Counter >= HackTime)
		{
			Hacking = false;
			TriggerEventClass(class'SeqEvent_TerminalHacked', self);
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
	}
}
