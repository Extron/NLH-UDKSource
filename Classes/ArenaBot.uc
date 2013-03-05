/*******************************************************************************
	ArenaBot

	Creation date: 15/10/2012 08:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaBot extends UDKBot;


/**
 * The bot's personality, which governs much of how the bot responds to events in a level.
 */
var BotPersonality Personality;

/**
 * The last location that the bot was in good condition at.
 */
var vector LastStableLocation;

/**
 * The location that the bot last saw its target.
 */
var vector LastSeenLocation;

/**
 * The last navigation point that the AI is or was wandering to.
 */
var NavigationPoint WanderTarget;

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
 * Keeps track of how long the bot has been idle.
 */
var float IdleCounter;

/**
 * The amount of time the bot has been searching for the target.
 */
var float SearchCounter;

/**
 * The maximum allowed time the bot can search for his target.
 */
var float SearchMax;

/**
 * Indicates that we have come into desirable range of our target after moving toward it.
 */
var bool ApproachedTarget;

/**
 * Indicates that the bot can shoot.
 */
var bool CanFire;

/**
 * Indicates that the bot should be searching for its target.
 */
var bool Searching;


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

			GoToState('Focusing');
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
		if (Searching)
		{
			GoToState('SearchingForTarget');
		}
		else if (IdleCounter > 4)
		{
			IdleCounter = 0;
			GoToState('Wandering');
		}
		else
		{
			GoToState('Idle');
		}
	}
}

function ArenaPawn FindNearestTarget()
{
	local ArenaPawn p;
	local ArenaPawn nearest;
	
	foreach WorldInfo.AllPawns(class'ArenaPawn', p)
	{
		if (p != Pawn && !p.Invisible)
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

function name GetAttack(Actor actor)
{
	return 'FireWeapon';
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
	
	if (cautionMeasure > 0.0)
		`log("Bot" @ self @ "is cautious.");
		
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
	
	if (aggresionMeasure > 0.0)
		`log("Bot" @ self @ "is aggresive.");
		
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
	event Tick(float dt)
	{
		global.Tick(dt);
		
		IdleCounter += dt;
	}
	
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
			LastSeenLocation = MoveTarget.Location;
			MoveTarget = None;
			Searching = true;
			
			`log("I should search for my target.");
			StopLatentExecution();
			Pawn.ZeroMovementVariables();
			
			GoToState('MovingToSearch');
		}
	}
	
Begin:
	if (Pawn != None)
		Pawn.GoToState('MoveToTarget');
		
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

/**
 * This state is for bots when they are actively engaging an emeny.  It forms a hub of sorts
 * from which attacks will originate.
 */
simulated state Focusing
{
Begin:
	if (Pawn != None)
		Pawn.GoToState('Focusing');
		
	if (Pawn.NeedToTurn(GetFocalPoint()))
		FinishRotation();

	GoToState(GetAttack(Focus));
}

simulated state FireWeapon
{
Begin:

	while(!AP_Bot(Pawn).CanShoot())
		Sleep(0.0);
		
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
	
	MoveTo(LastStableLocation);
	Pawn.ZeroMovementVariables();
	LatentWhatToDoNext();
}

simulated state Wandering
{
	event Tick(float dt)
	{
		local ArenaPawn target;
		
		global.Tick(dt);
		
		target = FindNearestTarget();
		
		if (target != None && CanSee(target))
		{
			MoveTarget = target;
			
			StopLatentExecution();
			Pawn.ZeroMovementVariables();
		}
	}
	
Begin:
	if (Pawn != None)
		Pawn.GoToState('Wandering');
		
	WanderTarget = FindRandomDest();
		
	MoveTo(WanderTarget.Location);
	Pawn.ZeroMovementVariables();
	LatentWhatToDoNext();
}

simulated state MovingToSearch
{
	event Tick(float dt)
	{
		local ArenaPawn target;
		
		global.Tick(dt);
		
		target = FindNearestTarget();
		
		if (target != None && CanSee(target))
		{
			MoveTarget = target;
			
			StopLatentExecution();
			Pawn.ZeroMovementVariables();
		}
	}
	
Begin:
	`log("Moving to search location.");
	MoveTo(LastSeenLocation);
	Pawn.ZeroMovementVariables();
	Searching = true;
	LatentWhatToDoNext();
}

simulated state SearchingForTarget
{
	event Tick(float dt)
	{
		local ArenaPawn target;
		
		global.Tick(dt);
		
		SearchCounter += dt;
		
		target = FindNearestTarget();
		
		if (target != None && CanSee(target))
		{
			MoveTarget = target;
			
			StopLatentExecution();
			Pawn.ZeroMovementVariables();
		}
	}
	
Begin:
	Sleep(SearchMax);
	LatentWhatToDoNext();
}

defaultproperties
{
	BotRange=1000
	BotFireRange=1000
	FireIntervalMax=2.5
	FireIntervalMin=0.25
	CanFire=true
}