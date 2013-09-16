/*******************************************************************************
	BTAction_NavigateTo

	Creation date: 26/08/2013 08:52
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Similar to MoveTo, but does path finding first to compute an appropriate path to the target location.  In contrast, MoveTo will simply attempt to move a bot
 * in a straight line to the destination, regardless of whether something is in the way or not.
 */
class BTAction_NavigateTo extends BTAction;


/**
 * The point to move toward.
 */
var vector Destination;

/**
 * During pathfinding, this will be set to incremental points along the path to get to the destination.
 */
var vector CurrentDestination;

/**
 * The actor to focus on during the navigation.
 */
var Actor Focus;

/**
 * The nearest distance needed to the point to complete movement.
 */
var float DestinationOffset;

/**
 * Indicates that the a partial path can be used if a full path cannot be found.
 */
var bool AllowPartialPath;

/**
 * Indicates that the bot should walk when it navigates.
 */
var bool ShouldWalk;


var private int IterCount;

/**
 * This delegate allows custom path constraints to be built for the path before path finding is run.  If no constraints are set, 
 * a default constraint set consisting of a Toward constraint and a At goal are used.
 */
delegate BuildConstraintsAndGoals(NavigationHandle handle, BTAction_NavigateTo sender);


simulated function bool HasDelegate(string delName)
{
	if (delName == "BuildConstraintsAndGoals")
		return true;
	else
		return super.HasDelegate(delName);
}

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
			if (binding[0] == "Destination")
				Destination = vector(binding[1]);
			else if (binding[0] == "DestinationOffset")
				DestinationOffset = float(binding[1]);
			else if (binding[0] == "AllowPartialPath")
				AllowPartialPath = bool(binding[1]);
			else if (binding[0] == "ShouldWalk")
				ShouldWalk = bool(binding[1]);
		}
	}
}

simulated function Reset()
{
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		if (Controller.NavigationHandle != None)
			Controller.NavigationHandle.ClearConstraints();
			
		Controller.StopLatentExecution();
		Controller.Pawn.ZeroMovementVariables();
		
		IterCount = 0;
	}
	
	super.Reset();
}

simulated function bool FindPath()
{
	if (Controller.NavigationHandle == None)
		return false;

	Controller.NavigationHandle.SetFinalDestination(Destination);
	
	if (BuildConstraintsAndGoals != None)
	{
		if (DisplayLog)
			`log(Controller $ ":" @ self @ "using custom nav goals.");
			
		BuildConstraintsAndGoals(Controller.NavigationHandle, self);
	}
	else
	{
		class'NavMeshPath_Toward'.static.TowardPoint(Controller.NavigationHandle, Destination);
		class'NavMeshGoal_At'.static.AtLocation(Controller.NavigationHandle, Destination, DestinationOffset, AllowPartialPath);
	}
	
	if (!Controller.NavigationHandle.PointReachable(Destination) && !Controller.NavigationHandle.FindPath())
		return false;
	
	return true;
}


state Running
{	
Begin:
	if (FindPath())
	{
		if (Controller.PointReachable(Destination))
		{
			Controller.BeginMoveTo(self, Destination, Focus, DestinationOffset, ShouldWalk);
			
			while (Controller.IsInState('MoveToState'))
				Sleep(0.0);
		}
		else
		{
			while (!Controller.Pawn.ReachedPoint(Destination, None))
			{
				Controller.NavigationHandle.GetNextMoveLocation(CurrentDestination, Controller.Pawn.GetCollisionRadius());
				
				if (!Controller.NavigationHandle.SuggestMovePreparation(CurrentDestination, Controller))
				{
					if (DisplayLog)
						`log(Controller $ ":" @ self @ "moving to" @ CurrentDestination);
					
					Controller.BeginMoveTo(self, CurrentDestination, Focus, 0, ShouldWalk);

					while (Controller.IsInState('MoveToState'))
						Sleep(0.0);
				}
				
				IterCount++;
				
				if (IterCount >= 100)
					break;
			}
		}
		
		if (IterCount < 100)
		{
			GotoState('Succeeded');
		}
		else
		{
			if (DisplayLog)
				`log(Controller $ ":" @ self @ "ran out of iterations");
			
			GotoState('Failed');
		}
	}
	else
	{
		if (DisplayLog)
			`log(Controller $ ":" @ self @ "failed to find a path to" @ Destination);
			
		GotoState('Failed');
	}
}

state Succeeded
{
Begin:
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		if (Controller.NavigationHandle != None)
			Controller.NavigationHandle.ClearConstraints();
			
		Controller.StopLatentExecution();
		Controller.Pawn.ZeroMovementVariables();
		
		IterCount = 0;
	}
}

state Failed
{
Begin:
	if (Controller.CurrentLatentNode == None || Controller.CurrentLatentNode == self)
	{
		if (Controller.NavigationHandle != None)
			Controller.NavigationHandle.ClearConstraints();
			
		Controller.StopLatentExecution();
		Controller.Pawn.ZeroMovementVariables();
		
		IterCount = 0;
	}
}