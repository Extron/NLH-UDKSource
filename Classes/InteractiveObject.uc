/*******************************************************************************
	InteractiveObject

	Creation date: 18/03/2013 15:16
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * An interactive object is something that the player can interact with using the interaction key.
 */
class InteractiveObject extends DynamicSMActor
	placeable;

/**
 * The radius from the object that the player must be to be able to interact with it.
 */
var(Interaction) float InteractionRadius;

/**
 * The message to report to the user when in range.
 */
var(Interaction) string InteractionMessage;


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
 * This is called when the object is being interacted with.
 */
simulated function InteractWith(Pawn user)
{
	`log("Interacting with object.");	
	TriggerEventClass(class'SeqEvent_ObjectInteracted', self, 0);
}

simulated function bool WithinRadius(Pawn user)
{
	return VSize(Location - user.Location) <= InteractionRadius;
}

simulated function string GetMessage()
{
	return "Press to" @ InteractionMessage;
}

defaultproperties
{
	SupportedEvents.Add(class'Arena.SeqEvent_ObjectInteracted')
}
