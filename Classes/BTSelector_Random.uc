/*******************************************************************************
	BTSelector_Random

	Creation date: 22/08/2013 13:01
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A random selector picks a child at random to run.  If a chosen child fails, a new child is picked.  If all children fail, then this node fails.
 * If a child succeeds, a new child is picked.
 */
class BTSelector_Random extends BTSelector;

/**
 * To ensure we keep track of failed nodes, store them here.
 */
var array<int> FailedChildren;

/**
 * Allows a bias to be attached to certain children.  A bias for a node indicates how many
 * "tickets" that node has in the "pot".  The more tickets, the more likely the node is picked.
 * By default, a uniform bias is used, where all nodes have 1 ticket.
 */
var array<int> NodeBiases;


var int Index;

simulated function Reset()
{
	Index = -1;
	FailedChildren.Length = 0;
	
	super.Reset();
}

simulated function AddChild(BehaviorTreeNode child)
{
	super.AddChild(child);
	
	NodeBiases.AddItem(1);
}

simulated function AddWeightedChild(BehaviorTreeNode child, int tickets)
{
	super.AddChild(child);
	
	NodeBiases.AddItem(tickets);
}

simulated function SetChildWeight(BehaviorTreeNode child, int tickets)
{
	if (Nodes.Find(child) > -1)
		NodeBiases[Nodes.Find(child)] = tickets;
}

simulated private function array<int> BuildPot()
{
	local array<int> pot;
	local int i;
	local int j;
	
	for (i = 0; i < NodeBiases.Length; i++)
	{
		for (j = 0; j < NodeBiases[i]; j++)
			pot.AddItem(i);
	}
	
	return pot;
}

state Running
{
	simulated function Update(float dt)
	{
		local array<int> pot;
		local int i;
		
		pot = BuildPot();
		
		if (Index > -1)
		{
			//`log(Controller $ ":" @ self @ "updating node" @ Nodes[Index]);
			
			Nodes[Index].Update(dt);
			
			if (Nodes[Index].IsInState('Failed') || Nodes[Index].IsInState('Succeeded'))
			{
				Nodes[Index].Reset();
				//`log("Node" @ Nodes[i] @ "Completed");
				Index = -1;
			}
		}
		else
		{
			//`log(Controller $ ":" @ self @ "picking new child" @ "Pot length" @ pot.Length);
			FailedChildren.Length = 0;
			
			while (FailedChildren.Length < Nodes.Length)
			{
				do
				{
					i = pot[Rand(pot.Length)];
				}
				until (FailedChildren.Find(i) == -1);
				
				Nodes[i].Update(dt);
				
				if (Nodes[i].IsInState('Failed'))
				{
					//`log("Node" @ Nodes[i] @ "failed.  Picking new node");
					FailedChildren.AddItem(i);
				}
				else
				{
					Index = i;
					//`log("Setting current node to" @ i @ Index);					
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