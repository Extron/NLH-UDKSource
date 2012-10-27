/*******************************************************************************
	ArenaBot

	Creation date: 15/10/2012 08:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaBot extends UDKBot;

/**
 * Indicates that we have come into desirable range of our target after moving toward it.
 */
var bool ApproachedTarget;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
	Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
	Pawn.SetMovementPhysics();
	
	WhatToDoNext();
}

event WhatToDoNext()
{
	if (Pawn == None)
		return;

	DecisionComponent.bTriggered = true;
}

protected function ExecuteWhatToDoNext()
{
	if (Pawn == None)
	{
		GoToState('Idle');
		return;
	}
		
	if (MoveTarget == None)
		FindNearestTarget();
		
	if (MoveTarget != None && Pawn != None)
	{
		if (Pawn.ReachedDestination(MoveTarget))
		{
			ApproachedTarget = true;
			GoToState('Idle');
		}
		else
		{
			GoToState('MoveToTarget');
		}
	}
	else
	{
		GoToState('Idle');
	}
}

function FindNearestTarget()
{
	local ArenaPawn p;
	
	foreach WorldInfo.AllPawns(class'ArenaPawn', p)
	{
		if (p != Pawn)
		{
			if (MoveTarget != None)
			{
				if (VSize(Pawn.Location - p.Location) < VSize(Pawn.Location - MoveTarget.Location))
					MoveTarget = p;
			}
			else
			{
				MoveTarget = p;
			}
		}
	}
}

auto state Idle
{
Begin:
	if (Pawn != None)
		Pawn.GoToState('Idle');
		
	LatentWhatToDoNext();
}

simulated state MoveToTarget
{
Begin:
	
	if (Pawn != None)
		Pawn.GoToState('MoveToTarget');
		
	if (MoveTarget == None || ApproachedTarget)
	{		
		LatentWhatToDoNext();
	}
	else
	{
		MoveToward(MoveTarget, MoveTarget);
		LatentWhatToDoNext();
	}
}