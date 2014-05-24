/*******************************************************************************
	BTSelector_Delayer

	Creation date: 24/08/2013 03:18
	Copyright (c) 2013, Trystan
*******************************************************************************/

/**
 * A type of decorator, a delayer has one child.  This child is only updated within a certain interval.  Upon updating, if this node is not allowed to 
 * run, it will fail, while if it can run, it will succeed or fail as the child does.  This generally only works when the Repeater is this node's parent.
 */
class BTSelector_Delayer extends BTSelector;

/**
 * The minimum amount of time to delay the child.
 */
var float MinDelay;

/**
 * The maximum amount of time to delay the child.
 */
var float MaxDelay;

/**
 * Indicates that the child can be run.
 */
var bool CanRun;


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
			if (binding[0] == "MinDelay")
				MinDelay = float(binding[1]);
			else if (binding[0] == "MaxDelay")
				MaxDelay = float(binding[1]);
			else if (binding[0] == "CanRun")
				CanRun = bool(binding[1]);
		}
	}
}


simulated function RestartDelay()
{
	CanRun = true;
}

state Running
{
	simulated function Update(float dt)
	{
		local BehaviorTreeNode node;
		
		node = Nodes[0];

		if (CanRun)
		{
			//`log(Controller $ ":" @ self @ "updating node" @ node);
			node.Update(dt);
			
			if (node.IsInState('Failed'))
			{
				//`log("Node failed");
				GotoState('Failed');
			}
			else if (node.IsInState('Succeeded'))
			{
				//`log("Node succeeded");
				
				GotoState('Succeeded');
				CanRun = false;
				
				if (MinDelay < 0)
					MinDelay = MaxDelay;
					
				SetTimer(Lerp(MinDelay, MaxDelay, FRand()), false, 'RestartDelay');
			}
		}
		else
		{
			GotoState('Failed');
		}
	}
}

defaultproperties
{
	CanRun=true
	MinDelay=-1
}