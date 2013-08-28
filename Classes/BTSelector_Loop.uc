/*******************************************************************************
	BTSelector_Loop

	Creation date: 22/08/2013 12:56
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Similar to a sequence, a loop runs its children in sequential order, but when it reaches the end, instead of succeeding, it starts over from the beginning.
 */
class BTSelector_Loop extends BTSelector;

/**
 * The index of the currently running child.
 */
var int Index;

simulated function Reset()
{
	Index = -1;
	
	super.Reset();
}

state Running
{
	simulated function Update(float dt)
	{
		local BehaviorTreeNode iter;
		local int i;
		
		if (Index > -1)
		{
			Nodes[Index].Update(dt);
			
			if (Nodes[Index].IsInState('Failed'))
			{
				GotoState('Failed');
			}
			else if (Nodes[Index].IsInState('Succeeded'))
			{
				if (Index == Nodes.Length - 1)
				{
					Index = 0;

					foreach Nodes(iter)
						iter.Reset();
				}
				else
				{
					Index++;
				}
			}
		}
		else
		{
			for (i = 0; i < Nodes.Length; i++)
			{
				Nodes[i].Update(dt);
				
				if (Nodes[i].IsInState('Failed'))
				{
					GotoState('Failed');
					break;
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