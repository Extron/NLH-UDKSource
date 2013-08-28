/*******************************************************************************
	BTSelector_Concurrent

	Creation date: 22/08/2013 13:11
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A concurrent selector runs all children every update.  This node fails when a single child fails, and succeeds when all children succeed.
 */
class BTSelector_Concurrent extends BTSelector;


state Running
{
	simulated function Update(float dt)
	{
		local int i;
		local int sucCount;
		
		for (i = 0; i < Nodes.Length; i++)
		{
			//`log(Controller $ ":" @ self @ "updating node" @ Nodes[i]);
			
			Nodes[i].Update(dt);
			
			if (Nodes[i].IsInState('Failed'))
			{
				//`log("Node" @ Nodes[i] @ "failed");
				GotoState('Failed');
				break;
			}
			else if (Nodes[i].IsInState('Succeeded'))
			{
				//`log("Node" @ Nodes[i] @ "succeeded");
				sucCount++;
				Nodes[i].Reset();
			}
		}
		
		if (sucCount == Nodes.Length)
			GotoState('Succeeded');
	}
}