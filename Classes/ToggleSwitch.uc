/*******************************************************************************
	ToggleSwitch

	Creation date: 28/04/2014 20:17
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A toggleable switch.
 */
class ToggleSwitch extends Switch
	placeable;

/**
 * A list of toggleable objects in the world that respond to this switch.
 */
var(Switch) array<IToggleableObject> Connections;

/**
 * The switch's current state (0 is up, 1 is down, etc).
 */
var byte ToggleState;

/**
 * The sound to make when the switch is toggled.
 */
var(Switch) SoundCue ToggleSound;


simulated function InteractWith(Pawn user)
{
	local IToggleableObject iter;
	
	ToggleState = 1 - ToggleState;
	
	super.InteractWith(user);
	TriggerEventClass(class'SeqEvent_SwitchToggled', self, 0);
	
	foreach Connections(iter)
		iter.Toggle();
		
	if (ToggleSound != None)
		PlaySound(ToggleSound);
}