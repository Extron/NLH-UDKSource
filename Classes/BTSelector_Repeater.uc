/*******************************************************************************
	BTSelector_Repeater

	Creation date: 24/08/2013 02:11
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A type of decorator, a repeater will run a single child repeatedly, either a finite amount of times, or infinitely, resetting the child when it succeeds or fails.  
 This type of node will generally not get to the succed or fail states, and if finite, will succeed regardless of the child status.
 */
class BTSelector_Repeater extends BTSelector;


/**
 * The number of repetitions that this node should do.
 */
var int Repetitions;

/**
 * The current number of repetitions that have been made.
 */
var int Count;


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
			if (binding[0] == "Repetitions")
				Repetitions = int(binding[1]);
		}
	}
}

state Running
{
	simulated function Update(float dt)
	{
		local BehaviorTreeNode node;
		
		node = Nodes[0];

		node.Update(dt);
		
		if (node.IsInState('Failed') || node.IsInState('Succeeded'))
		{
			node.Reset();
			
			Count++;
		
			if (Repetitions > -1 && Count >= Repetitions)
				GotoState('Succeeded');
		}
	}
}

defaultproperties
{
	Repetitions=-1
}