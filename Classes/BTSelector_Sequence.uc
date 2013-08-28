/*******************************************************************************
	BTSelector_Sequence

	Creation date: 21/08/2013 23:21
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A sequence node will iterate through its children in order.  When a child succeeds, the next child begins running.  
 * If a child fails in the sequence, the whole sequence fails.
 */
class BTSelector_Sequence extends BTSelector;

/**
 * The index of the currently running child.
 */
var int Index;


/**
 * This delegate is called when we advance to the next child node in the sequence.
 */
delegate OnAdvanceSequence(BehaviorTreeNode prev, BehaviorTreeNode next, int newIndex);

simulated function bool HasDelegate(string delName)
{
	if (delName == "OnAdvanceSequence")
		return true;
	else
		return super.HasDelegate(delName);
}

simulated function Reset()
{
	Index = -1;
	
	super.Reset();
}

state Running
{
	simulated function Update(float dt)
	{
		local int i;
		
		if (Index > -1)
		{
			if (DisplayLog)
				`log(Controller $ ":" @ self @ "updating" @ Index $ "th node" @ Nodes[Index]);
			
			Nodes[Index].Update(dt);
			
			if (Nodes[Index].IsInState('Failed'))
			{
				GotoState('Failed');
				return;
			}
			else if (Nodes[Index].IsInState('Succeeded'))
			{
				if (Index == Nodes.Length - 1)
				{
					GotoState('Succeeded');
					return;
				}
				else
				{
					Index++;
					OnAdvanceSequence(Nodes[Index - 1], Nodes[Index], Index);
				}
			}
		}
		else
		{
			for (i = 0; i < Nodes.Length; i++)
			{
				if (DisplayLog)
					`log(Controller $ ":" @ self @ "updating" @ i $ "th node" @ Nodes[i]);
				
				Nodes[i].Update(dt);
				
				if (Nodes[i].IsInState('Failed'))
				{
					GotoState('Failed');
					return;
				}
				else
				{
					Index = i;
					break;
				}
			}
			
			if (Index == -1)
				GotoState('Failed');
		}
	}
}

defaultproperties
{
	Index=-1
}