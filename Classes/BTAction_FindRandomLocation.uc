/*******************************************************************************
	BTAction_FindRandomLocation

	Creation date: 23/04/2014 13:32
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Picks a random location for the pawn.
 */
class BTAction_FindRandomLocation extends BTAction;

/**
 * When Reachable is set to true, this allows a specific AABB region around the pawn to always be considered reachable, regardless 
 * of whether it is or not.
 */
var vector ValidBox;

/**
 * The maximum radius of the circle centered at the pawn to find the location within.
 */
var float MaxRadius;

/**
 * The minimum radius of the circle centered at the pawn to find the location within.
 */
var float MinRadius;

/**
 * Indicates that the position must be reachable from the pawn's staring position by the pawn should it walk.
 */
var bool Reachable;


state Running
{
	simulated function BeginState(name prev)
	{
		local array<vector> possibles;
		local vector extent;
		local float r, h;
		
		OnRunning(self);
		
		Controller.Pawn.GetBoundingCylinder(r, h);
		extent.x = r * 2;
		extent.y = r * 2;
		extent.z = h;

		class'NavigationHandle'.static.GetValidPositionsForBox(Controller.Pawn.Location, MaxRadius, extent, Reachable, possibles, , MinRadius, ValidBox);
		
		if (possibles.Length > 0)
		{
			Controller.Destination = possibles[Rand(possibles.Length)];
			GotoState('Succeeded');
		}
		else
		{
			GotoState('Failed');	
		}
	}
}