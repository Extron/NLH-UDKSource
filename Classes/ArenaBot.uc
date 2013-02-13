/*******************************************************************************
	ArenaBot

	Creation date: 15/10/2012 08:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaBot extends UDKBot;


/**
 * The last location that the bot was in good condition at.
 */
var vector LastStableLocation;

/**
 * The distance away from the player that the bot needs to move to to become idle.
 */
var float BotRange;

/**
 * The range of the bot's targeting when shooting.
 */
var float BotFireRange;

/**
 * The minimum amount of time that the bot needs to fire again.
 */
var float FireIntervalMin;

/**
 * The maximum amount of time that the bot needs to fire again.
 */
var float FireIntervalMax;

/**
 * The amount of time that the bot was last shot at.
 */
var float LastShotAtDuration;

/**
 * The amount of time the bot is being stunned for.
 */
var float StunTime;

/**
 * Indicates that we have come into desirable range of our target after moving toward it.
 */
var bool ApproachedTarget;

/**
 * Indicates that the bot can shoot.
 */
var bool CanFire;

event Tick(float dt)
{
	super.Tick(dt);
	
	LastShotAtDuration += dt;
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	PlayerReplicationInfo = spawn(class'Arena.ArenaPRI', self);
	Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
	Pawn.SetMovementPhysics();
	
	LastShotAtDuration = 0;
	
	ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn), ArenaGRI(WorldInfo.GRI).Constants);
	
	WhatToDoNext();
}

function CleanupPRI()
{
	`log("PRI" @ PlayerReplicationInfo);
	
	super.CleanupPRI();
}

function NotifyKilled(Controller killer, Controller killed, Pawn killedPawn, class<DamageType> damageType)
{
	super.NotifyKilled(killer, killed, killedPawn, damageType);
	
	if (ArenaTeamInfo(PlayerReplicationInfo.Team) != None)
		ArenaTeamInfo(PlayerReplicationInfo.Team).TeamMemberKilled(self);
}

event WhatToDoNext()
{
	if (Pawn == None)
		return;

	DecisionComponent.bTriggered = true;
}

protected function ExecuteWhatToDoNext()
{
	local ArenaPawn nearestPawn;
	
	if (Pawn == None)
	{
		GoToState('Idle');
		return;
	}
	
	
	nearestPawn = FindNearestTarget();
		
	if (nearestPawn != None && Pawn != None && CanSee(nearestPawn))
	{
		if (VSize(Pawn.Location - nearestPawn.Location) < BotFireRange)
		{
			Focus = nearestPawn;

			GoToState('FireWeapon');
		}
		else if (Pawn.ReachedDestination(nearestPawn) || VSize(Pawn.Location - nearestPawn.Location) < BotRange)
		{
			ApproachedTarget = true;
			GoToState('Idle');
		}
		else
		{
			MoveTarget = nearestPawn;
			ApproachedTarget = false;
			GoToState('MoveToTarget');
		}
	}
	else
	{
		GoToState('Idle');
	}
}

function ArenaPawn FindNearestTarget()
{
	local ArenaPawn p;
	local ArenaPawn nearest;
	
	foreach WorldInfo.AllPawns(class'ArenaPawn', p)
	{
		if (p != Pawn)
		{			
			if (p.PlayerReplicationInfo != None && PlayerReplicationInfo != None)
			{
				if (p.PlayerReplicationInfo.Team != None && p.PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)
				{
					if (nearest != None)
					{
						if (VSize(Pawn.Location - p.Location) < VSize(Pawn.Location - nearest.Location))
							nearest = p;
					}
					else
					{
						nearest = p;
					}
				}
			}
		}
	}
	
	return nearest;
}

function ShootAt(Actor actor)
{
	local float a;
	
	if (Pawn != None && CanFire)
	{
		Pawn.StartFire(0);
		CanFire = false;
		
		Pawn.StopFire(0);
		
		a = FRand();
		
		SetTimer(FireIntervalMin * (1 - a) + FireIntervalMax * a, false, 'ReactivateFire');
	}
}

/**
 * Sets the bot to be stunned, meaning that it cannot move.
 */
function Stun(float time)
{
	StunTime = time;
	GoToState('Stunned');
}


/**
 * This function determines if the bot should be cautious about attacking the current target.  This is dependant on the bot's
 * and player's health, the target's and bot's currently equipped weapon, the number of friendly and enemy actors in the vicinity,
 * and how long ago the player took a shot at the bot.
 *
 * @returns Returns true if the bot should be cautious, false if not.
 */
function bool IsCautious()
{
	local float cautionMeasure;
	
	cautionMeasure = 0;
	
	if (ArenaPawn(Focus) != None)
	{
		cautionMeasure += 0.5 * Pawn.HealthMax / float(Pawn.Health);
		
		cautionMeasure -= 0.5 * ArenaPawn(Focus).HealthMax / float(ArenaPawn(Focus).Health);
		
		//Reduce the need for caution for every near friendly bot within 50 units.
		cautionMeasure -= BotsNear(50) * 0.5;
		
		cautionMeasure -= LastShotAtDuration * 0.15;
	}
	
	return cautionMeasure > 0.0;
}

/**
 * This function determines if the bot should be aggressive about attacking the current target.  This is dependant on the bot's
 * and player's health, the target's and bot's currently equipped weapon, the number of friendly and enemy actors in the vicinity,
 * and how long ago the player took a shot at the bot.
 *
 * @returns Returns true if the bot should be cautious, false if not.
 */
function bool IsAggressive()
{
	local float aggresionMeasure;
	
	if (ArenaPawn(Focus) != None)
	{
		aggresionMeasure -= 0.5 * Pawn.HealthMax / float(Pawn.Health);
		
		aggresionMeasure += 0.5 * ArenaPawn(Focus).HealthMax / float(ArenaPawn(Focus).Health);
		
		//Reduce the need for caution for every near friendly bot within 50 units.
		aggresionMeasure += BotsNear(50) * 0.5;
	}
	
	return aggresionMeasure > 0.0;
}

/**
 * This function determines if the bot should be retreating to cover.  This is dependant on the bot's
 * and player's health, the target's and bot's currently equipped weapon, the number of friendly and enemy actors in the vicinity,
 * and how long ago the player took a shot at the bot.
 *
 * @returns Returns true if the bot should be cautious, false if not.
 */
function bool IsRetreating()
{
	local float retreatMeasure;
	
	retreatMeasure = 0;
	
	if (ArenaPawn(Focus) != None)
	{
		retreatMeasure += 0.75 * Pawn.HealthMax / float(Pawn.Health);
		
		retreatMeasure -= 0.75 * ArenaPawn(Focus).HealthMax / float(ArenaPawn(Focus).Health);
		
		//Reduce the need for caution for every near friendly bot within 50 units.
		retreatMeasure -= BotsNear(50) * 0.25;
		
		retreatMeasure -= LastShotAtDuration * 0.05;
	}
	
	return retreatMeasure > 0.0;
}

/**
 * Counts the amount of (friendly) bots that are near this bot.
 *
 * @param radius - The radius in which to search.
 * @returns Returns the number of bots that are near.
 */
function int BotsNear(float radius)
{
	local ArenaPawn b;
	local int count;
	
	foreach WorldInfo.AllPawns(class'ArenaPawn', b, Pawn.Location, radius)
	{
		if (Pawn.GetTeam().TeamIndex == b.GetTeam().TeamIndex)
			count++;
	}
	
	return count;
}

function ReactivateFire()
{
	CanFire = true;
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
	event Tick(float dt)
	{
		global.Tick(dt);
		
		if (VSize(Pawn.Location - MoveTarget.Location) < BotRange)
		{			
			ApproachedTarget = true;
			
			StopLatentExecution();
			Pawn.ZeroMovementVariables();
		}
		else if (Pawn(MoveTarget) != None && !CanSee(Pawn(MoveTarget)))
		{
			MoveTarget = None;
			
			//TODO: This needs to be a better algorithm, to do a search or something.
			StopLatentExecution();
			Pawn.ZeroMovementVariables();
		}
	}
	
Begin:
	if (ApproachedTarget)
	{	
		LatentWhatToDoNext();
	}
	else if (MoveTarget != None)
	{
		MoveToward(MoveTarget, MoveTarget);
		LatentWhatToDoNext();
	}
	else
	{
		GoToState('Idle');
	}
}

simulated state FireWeapon
{
Begin:

	if (Pawn.NeedToTurn(GetFocalPoint()))
		FinishRotation();
			
	ShootAt(None);
	LatentWhatToDoNext();
}

simulated state Stunned
{
Begin:
	if (Pawn != None)
		Pawn.GoToState('Stunned');
		
	LastStableLocation = Pawn.Location;
	
	Sleep(StunTime);
	GoToState('Recovering');
}

simulated state Recovering
{
Begin:
	if (Pawn != None)
		Pawn.GoToState('Recovering');
		
	`log("Moving to:" @ LastStableLocation);
	
	MoveTo(LastStableLocation);
	LatentWhatToDoNext();
}

defaultproperties
{
	BotRange=750
	BotFireRange=500
	FireIntervalMax=2.5
	FireIntervalMin=0.25
	CanFire=true
}