/*******************************************************************************
	WeaponLocker

	Creation date: 27/05/2013 23:13
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponLocker extends InteractiveObject
	placeable;

var class<GFx_WeaponLocker> UIClass;

simulated function InteractWith(Pawn user)
{
	super.InteractWith(user);
	
	if (ArenaPlayerController(user.Owner) != None && ArenaHUD(ArenaPlayerController(user.Owner).MyHUD) != None)
	{
		ArenaHUD(ArenaPlayerController(user.Owner).MyHUD).DisplayOverlayMenu(UIClass, false);
	}
}

defaultproperties
{
	UIClass=class'GFx_WeaponLocker'	
	
	InteractionMessage="use weapon locker."
	InteractionRadius=200
}
