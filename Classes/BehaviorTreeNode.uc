/*******************************************************************************
	BehaviorTreeNode

	Creation date: 21/08/2013 23:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A behavior tree is a nifty structure to help manage AI coding.  It is a tree structure, where every leaf results in the NPC doing something.
 * when a behavior tree is updated, it traverses the structure to find a leaf to run.  Branch nodes (non-leaf nodes) contain the logic that picks 
 * which leaf to run.
 */
class BehaviorTreeNode extends Actor
	abstract;

	
/**
 * The parent node of this node.  Will be None if this node is root.
 */
var BehaviorTreeNode Parent;

/**
 * The controller that this node is acting for.
 */
var ArenaBot Controller;

/**
 * An ID string that allows nodes to be named, which is useful for finding specific nodes within a tree.
 */
var string ID;

/**
 * For debugging purposes, each node has the ability to display its own logs.
 */
var bool DisplayLog;


/**
 * Delegate called when this node enters its running state.
 */
delegate OnRunning(BehaviorTreeNode sender);

/**
 * Delegate called when this node enters its succeeded state.
 */
delegate OnSucceeded(BehaviorTreeNode sender);

/**
 * Delegate called when this node enters its failed state.
 */
delegate OnFailed(BehaviorTreeNode sender);


/**
 * Sets the controller that owns the current node for this node and all children nodes.
 */
simulated function SetController(ArenaBot bot)
{
	Controller = bot;
}

/**
 * Parses a list of parameter assignment strings and sets the corresponding parameters.  Should be overridden in child classes.
 */
simulated function SetParameters(array<string> parameters)
{
	local array<string> binding;
	local int i;
	
	for (i = 0; i < parameters.Length; i++)
	{
		
		binding = SplitString(parameters[i], "=");
		
		if (binding.Length == 2)
		{
			if (binding[0] ==  "DisplayLog")
				DisplayLog = bool(binding[1]);
				
			if (binding[0] == "ID")
				ID = binding[1];
		}
	}
}

simulated function bool HasDelegate(string delName)
{
	if (delName == "OnRunning" || delName == "OnSucceeded" || delName == "OnFailed")
		return true;
		
	return false;
}

/**
 * Searches the tree to find a node with the specified node ID.
 */
simulated function BehaviorTreeNode FindNode(string nodeID)
{
	if (ID == nodeID)
		return self;
	else
		return None;
}

simulated function Reset()
{
	if (DisplayLog)
		`log(Controller $ ":" @ self @ "resetting");
	GotoState('Ready');
}

simulated function Update(float dt)
{
	if (IsInState('Ready'))
	{
		GotoState('Running');
		Update(dt);
	}
}
	
simulated function TreeDisplayLog(bool display)
{
	DisplayLog = display;
}

auto state Ready
{
}

state Running
{
	simulated event BeginState(name prev)
	{
		if (DisplayLog)
			`log(Controller $ ":" @ self @ "is running");
			
		OnRunning(self);
	}
}

state Succeeded
{
	simulated event BeginState(name prev)
	{
		if (DisplayLog)
			`log(Controller $ ":" @ self @ "succeeded");
			
		OnSucceeded(self);
	}
}

state Failed
{
	simulated event BeginState(name prev)
	{
		if (DisplayLog)
			`log(Controller $ ":" @ self @ "failed");
			
		OnFailed(self);
	}
}