/*******************************************************************************
	BTAction_Idle

	Creation date: 24/08/2013 03:05
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A node that does nothing for a set time period.
 */
class BTAction_Idle extends BTAction;

/**
 * The minimum amount of time to do nothing for.  If this is set to -1, then MaxDuration will be used as the idle time.
 */
var float MinDuration;

/**
 * The maximumn amount of time to do nothing for.
 */
var float MaxDuration;


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
			if (binding[0] == "MinDuration")
				MinDuration = float(binding[1]);
			else if (binding[0] == "MaxDuration")
				MaxDuration = float(binding[1]);
		}
	}
}

state Running
{
	simulated function EndAction()
	{
		GotoState('Succeeded');
	}
	
Begin:
	if (MinDuration < 0)
		MinDuration = MaxDuration;
		
	SetTimer(Lerp(MinDuration, MaxDuration, FRand()), false, 'EndAction');
}

defaultproperties
{
	MinDuration = -1;
}