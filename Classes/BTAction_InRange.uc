/*******************************************************************************
	BTAction_InRange

	Creation date: 24/08/2013 03:34
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This node succeeds when the controller is within a specified distance from a specified target, and fails otherwise.
 */
class BTAction_InRange extends BTAction;


/**
 * The target to test the distance from.
 */
var Actor Target;

/**
 * The maximum allowed distance from the target.
 */
var float Range;


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
			if (binding[0] == "Range")
					Range = float(binding[1]);
		}
	}
}

state Running
{
	simulated function BeginState(name prev)
	{
		OnRunning(self);

		if (Target == None)
		{
			GotoState('Failed');
			return;
		}
		
		//`log("InRange distance" @ VSize(Target.Location - Controller.Pawn.Location));
		
		if (VSize(Target.Location - Controller.Pawn.Location) <= Range)
			GotoState('Succeeded');
		else
			GotoState('Failed');
	}
}