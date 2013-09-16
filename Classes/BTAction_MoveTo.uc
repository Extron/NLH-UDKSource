/*******************************************************************************
	BTAction_MoveTo

	Creation date: 22/08/2013 12:26
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BTAction_MoveTo extends BTAction;

/**
 * The location to move to.
 */
var vector Destination;

/**
 * The actor to face while moving.
 */
var Actor Focus;

/**
 * The destination offset from the target to stop at.
 */
var float DestinationOffset;

/**
 * Indicates that the NPC should walk to the destination.
 */
var bool ShouldWalk;


/**
 * Parses a list of parameter assignment strings and sets the corresponding parameters.  Should be overridden in child classes.
 */
simulated function SetParameters(array<string> parameters)
{
	local array<string> binding;
	local int i;
		
	super.SetParameters(parameters);
	
	for (i = 0; i < parameters.Length; i++)
	{
		binding = SplitString(parameters[i], "=");
		
		if (binding.Length == 2)
		{
			if (binding[0] == "Destination")
				Destination = vector(binding[1]);
			else if (binding[0] == "DestinationOffset")
				DestinationOffset = float(binding[1]);
			else if (binding[0] == "ShouldWalk")
				ShouldWalk = bool(binding[1]);
		}
	}
}

simulated function Reset()
{
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		Controller.StopLatentExecution();
		Controller.Pawn.ZeroMovementVariables();
		Controller.GotoState('Idle');
	}
	
	super.Reset();
}

state Running
{
Begin:
	//We don't want to short circuit any states that may be running latent code, so if we are not in the default state, don't attempt to 
	//change the state.
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		Controller.BeginMoveTo(self, Destination, Focus, DestinationOffset, ShouldWalk);
		
		while (!Controller.IsInState('Idle'))
			Sleep(0.0);
			
		GotoState('Succeeded');
	}
	else
	{
		GotoState('Failed');
	}
}

state Succeeded
{
Begin:
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		Controller.StopLatentExecution();
		Controller.Pawn.ZeroMovementVariables();
		Controller.GotoState('Idle');
	}
}

state Failed
{
Begin:
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		Controller.StopLatentExecution();
		Controller.Pawn.ZeroMovementVariables();
		Controller.GotoState('Idle');
	}
}