/*******************************************************************************
	BTSelector_Priority

	Creation date: 22/08/2013 12:44
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A priority selector tries to find a child to run, testing children in order of priority.  If a child should fail, then the next child in
 * line is run.  This node fails when all children fail, and succeeds when one child succeeds.  If a higher priority child is found that can
 * run, the previous running child is cancelled.
 */
class BTSelector_Priority extends BTSelector;


/**
 * The index of the previous running child.
 */
var int Index;


state Running
{
	simulated function Update(float dt)
	{
		local int i;
		
		for (i = 0; i < Nodes.Length; i++)
		{				
			if (DisplayLog)
				`log(Controller $ ":" @ self @ "updating" @ i $ "th node" @ Nodes[i]);
				
			Nodes[i].Update(dt);
			
			if (Nodes[i].IsInState('Running'))
			{
				if (Index > -1 && Index != i)
					Nodes[Index].Reset();
					
				Index = i;
				break;
			}
			else if (Nodes[i].IsInState('Succeeded'))
			{
				if (Index > -1 && Index != i)
					Nodes[Index].Reset();
				
				GotoState('Succeeded');
				break;
			}
			else if (Nodes[i].IsInState('Failed'))
			{
				Nodes[i].Reset();
				
				if (Index == i)
					Index = -1;
			}
		}
		
		if (Index == -1)
			GotoState('Failed');
	}
}

defaultproperties
{
	Index=-1
}