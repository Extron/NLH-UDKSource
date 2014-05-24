/*******************************************************************************
	WeaponLocker

	Creation date: 27/05/2013 23:13
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponLocker extends DynamicSMActor implements(IInteractiveObject)
	placeable;

var class<GFx_WeaponLocker> UIClass;

var float InteractionRadius;

simulated function Tick(float dt)
{
	local ArenaPawn iter;
	
	super.Tick(dt);
	
	foreach WorldInfo.AllPawns(class'Arena.ArenaPawn', iter, Location, InteractionRadius)
	{
		iter.SetNearestInterObj(self);
	}
}

/**
 * Determines if a player is in position to use the switch.
 */
simulated function bool IsPlayerNear(Pawn user)
{
	return VSize(Location - user.Location) <= InteractionRadius && user.Controller.LineOfSightTo(self);
}

simulated function InteractWith(Pawn user)
{
	if (ArenaPlayerController(user.Owner) != None && ArenaHUD(ArenaPlayerController(user.Owner).MyHUD) != None)
		ArenaHUD(ArenaPlayerController(user.Owner).MyHUD).DisplayOverlayMenu(UIClass, false);
}


/**
 * This is called when the pawn releases the interaction button.
 */
simulated function Release(Pawn pawn)
{
}

/**
 * Gets the message the interactive object displays to the HUD when the player is near.
 */
simulated function string GetMessage()
{
	return "Press <use> to open weapon locker";
}

/**
 * Indicates whether the interactive object requires the player to hold down the use button to continue interacting with it.
 */
simulated function bool MustHold()
{
	return false;
}

/**
 * Gets the length the player must hold down the use button for before the object is activated.
 */
simulated function float GetTriggerDuration()
{
	return 0.0;
}

/**
 * Gets the distance from the object to a specified actor.
 */
simulated function float GetDistanceFrom(Actor actor)
{
	return VSize(Location - actor.Location);
}

defaultproperties
{
	UIClass=class'GFx_WeaponLocker'	

	InteractionRadius=200
}
