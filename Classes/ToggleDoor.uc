/*******************************************************************************
	ToggleDoor

	Creation date: 27/05/2014 08:20
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A Toggle Door requires the user to hit the use button when near to open or close the door.  Further, the door stays
 * in the new state until another user interacts with it.
 */
class ToggleDoor extends Door implements(IInteractiveObject);

/**
 * The text that is displayed to the player when approaching the switch.
 */
var(Door) string DoorMessage;

/**
 * The interaction radius of the switch, which players need to be within to activate.
 */
var(Door) float InteractionRadius;

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

/**
 * This is called when the object is being interacted with.
 */
simulated function InteractWith(Pawn user)
{
	TriggerEventClass(class'SeqEvent_ObjectInteracted', self, 0);
	
	if (Open)
		CloseDoor();
	else
		OpenDoor();
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
	return "Press <use> to" @ DoorMessage;
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
	SupportedEvents.Add(class'Arena.SeqEvent_ObjectInteracted')
	InteractionRadius=256
}