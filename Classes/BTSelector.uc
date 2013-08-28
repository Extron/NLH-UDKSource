/*******************************************************************************
	BTSelector

	Creation date: 21/08/2013 23:08
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BTSelector extends BehaviorTreeNode
	abstract;

var array<BehaviorTreeNode> Nodes;

simulated function SetController(ArenaBot bot)
{
	local BehaviorTreeNode iter;
	
	super.SetController(bot);
	
	foreach Nodes(iter)
		iter.SetController(bot);
}

simulated function InsertChild(BehaviorTreeNode child, int index)
{
	child.Parent = self;
	Nodes.InsertItem(index, child);
}

simulated function AddChild(BehaviorTreeNode child)
{
	child.Parent = self;
	Nodes.AddItem(child);
}

/**
 * Searches the tree to find a node with the specified node ID.
 */
simulated function BehaviorTreeNode FindNode(string nodeID)
{
	local BehaviorTreeNode iter;
	local BehaviorTreeNode node;
	
	foreach Nodes(iter)
	{
		node = iter.FindNode(nodeID);
		
		if (node != None)
			return node;
	}
	
	if (node != None)
		return super.FindNode(nodeID);
}

simulated function Reset()
{
	local BehaviorTreeNode iter;
	
	foreach Nodes(iter)
		iter.Reset();
		
	super.Reset();
}

simulated function TreeDisplayLog(bool display)
{
	local BehaviorTreeNode iter;
	
	super.TreeDisplayLog(display);
	
	foreach Nodes(iter)
		iter.TreeDisplayLog(display);
}