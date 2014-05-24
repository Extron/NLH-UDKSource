/*******************************************************************************
	Bot_Crawler

	Creation date: 21/04/2014 11:19
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Bot_Crawler extends ArenaBot;

var BTAction_Condition EvadeCondition;

/**
 * The maximum range at which the crawler can jump at the player.
 */
var float JumpRangeMax;

/**
 * The minimub range at which the cravler can jump at the player.
 */
var float JumpRangeMin;

event PostBeginPlay()
{
	super.PostBeginPlay();
	
	BTSource = 	"<BTSelector_Repeater>" $ 
					"<BTSelector_Priority>" $ 
						"<BTSelector_Sequence>" $
							"<BTAction_Condition ID=EvadeCondition></BTAction_Condition>," $
							"<BTSelector_Loop>" $
								"<BTAction_FindRandomLocation MaxRadius=500 MinRadius=64 Reachable=true></BTAction_FindRandomLocation>," $
								"<BTAction_Condition OnRunning=CheckEvadeDirection></BTAction_Condition>" $
							"</BTSelector_Loop>," $ 
							"<BTAction_Jump MaxVelocity=500 OnRunning=Evade></BTAction_Jump>" $
						"</BTSelector_Sequence>," $
						"<BTSelector_Concurrent>" $
							"<BTAction_InRange Range=" $ BotRange $ " OnRunning=InRangeFocus></BTAction_InRange>," $
							"<BTSelector_Repeater>" $ 
								"<BTSelector_Delayer MinDelay=" $ FireIntervalMin $ " MaxDelay=" $ FireIntervalMax $ ">" $
									"<BTSelector_Sequence>" $
										"<BTAction_Turn></BTAction_Turn>," $
										"<BTAction_ShootAt></BTAction_ShootAt>" $
									"</BTSelector_Sequence>" $
								"</BTSelector_Delayer>" $
							"</BTSelector_Repeater>" $
						"</BTSelector_Concurrent>," $
						"<BTSelector_Sequence>" $
							"<BTAction_FindTarget></BTAction_FindTarget>," $
							"<BTAction_MoveToward DestinationOffset=" $ BotRange - 100 $ " OnRunning=MoveTowardFocus></BTAction_MoveToward>" $
						"</BTSelector_Sequence>," $
						"<BTSelector_Sequence>" $
							"<BTAction_NavigateTo OnRunning=Investigate></BTAction_NavigateTo>," $
							"<BTAction_Idle MinDuration=0.25 MaxDuration=1.5></BTAction_Idle>," $
							"<BTAction_NavigateTo OnRunning=Search></BTAction_NavigateTo>," $
							"<BTSelector_Repeater Repetitions=2>" $
								"<BTSelector_Sequence>" $
									"<BTAction_Idle MinDuration=0.25 MaxDuration=1.5></BTAction_Idle>," $
									"<BTAction_NavigateTo OnRunning=MoveToRandom BuildConstraintsAndGoals=NavGoalsRandom></BTAction_NavigateTo>" $
								"</BTSelector_Sequence>" $
							"</BTSelector_Repeater>" $
						"</BTSelector_Sequence>," $
						"<BTSelector_Sequence>" $
							"<BTSelector_Repeater>" $
								"<BTSelector_Sequence>" $
									"<BTAction_Idle MinDuration=5 MaxDuration=15></BTAction_Idle>," $
									"<BTAction_NavigateTo OnRunning=MoveToRandom BuildConstraintsAndGoals=NavGoalsRandom ShouldWalk=true></BTAction_NavigateTo>" $
								"</BTSelector_Sequence>" $
							"</BTSelector_Repeater>" $
						"</BTSelector_Sequence>" $
					"</BTSelector_Priority>" $
				"</BTSelector_Repeater>";
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	
	if (BTRoot != None)
		EvadeCondition = BTAction_Condition(BTRoot.FindNode("EvadeCondition"));
}

event Tick(float dt)
{
	super.Tick(dt);
	
	if (LastShotAtDuration > 0)
		EvadeCondition.Condition = false;
}

function ShotAt(ArenaWeapon weap, Actor shooter, vector traceLoc, vector direction)
{	
	local float rand;
	
	LastShotAtDuration = 0;
	EvadeDirection = traceLoc - Pawn.Location;
	Attacker = shooter;

	if (!IsAggressive())
	{
		if (IsCautious())
			rand = FRand() + 0.5;
		else
			rand = FRand();
			
		if (rand > 0.6)
			EvadeCondition.Condition = true;
	}
	else
	{
		EvadeCondition.Condition = false;
	}
}

/**
 * Assigns a function within this class to a specified delegate in a BT node.  This should be implemented per each child class
 * that requires a specific behavior tree.
 */
event AssignNodeDelegate(BehaviorTreeNode node, string delegateTarget, string funcName)
{		
	if (funcName == "Investigate" && delegateTarget == "OnRunning")
		node.OnRunning = Investigate;
		
	if (funcName == "Search" && delegateTarget == "OnRunning")
		node.OnRunning = Search;
		
	if (funcName == "InRangeFocus" && delegateTarget == "OnRunning")
		node.OnRunning = InRangeFocus;
		
	if (funcName == "MoveTowardFocus" && delegateTarget == "OnRunning")
		node.OnRunning = MoveTowardFocus;
		
	if (funcName == "MoveToRandom" && delegateTarget == "OnRunning")
		node.OnRunning = MoveToRandom;
		
	if (funcName == "NavGoalsRandom" && delegateTarget == "BuildConstraintsAndGoals")
		BTAction_NavigateTo(node).BuildConstraintsAndGoals = NavGoalsRandom;
		
	if (funcName == "Evade" && delegateTarget == "OnRunning")
		node.OnRunning = Evade;
		
	if (funcName == "CheckEvadeDirection" && delegateTarget == "OnRunning")
		node.OnRunning = CheckEvadeDirection;
}

event Evade(BehaviorTreeNode sender)
{
	if (Attacker != None)
	{
		Focus = Attacker;
		
		BTAction_Jump(sender).Destination = Destination;
		BTAction_Jump(sender).Gravity = GetGravityZ();
	}
	else
	{
		sender.GotoState('Failed');
	}
}

event CheckEvadeDirection(BehaviorTreeNode sender)
{
	if (EvadeDirection dot (Destination - Pawn.Location) >= 0)
		BTAction_Condition(sender).Condition = true;
	else
		BTAction_Condition(sender).Condition = false;
}

event Investigate(BehaviorTreeNode sender)
{
	if (Focus != None)
	{
		LastSeenLocation = Focus.Location;
		LastSeenDirection = Normal(Focus.Velocity);
		BTAction_NavigateTo(sender).Destination = Focus.Location;
		Focus = None;
	}
	else
	{
		sender.GotoState('Failed');
	}
}

event Search(BehaviorTreeNode sender)
{
	local vector dest;
	
	if (VSize(LastSeenDirection) > 0)
	{
		dest = LastSeenDirection * Lerp(500, 2000, FRand()) + Pawn.Location;
		
		if (NavigationHandle.ComputeValidFinalDestination(dest))
			BTAction_NavigateTo(sender).Destination = dest;
		else
			sender.GotoState('Failed');
	}
	else
	{
		sender.GotoState('Failed');
	}
}

event InRangeFocus(BehaviorTreeNode sender)
{
	BTAction_InRange(sender).Target = Focus;
}

event MoveTowardFocus(BehaviorTreeNode sender)
{
	BTAction_MoveToward(sender).Target = Focus;
}

event NavGoalsRandom(NavigationHandle handle, BTAction_NavigateTo sender)
{
	class'NavMeshPath_Toward'.static.TowardPoint(handle, sender.Destination);
	class'NavMeshPath_WithinTraversalDist'.static.DontExceedMaxDist(handle, 2000);
	class'NavMeshGoal_At'.static.AtLocation(handle, sender.Destination, sender.DestinationOffset, sender.AllowPartialPath);
}

event MoveToRandom(BehaviorTreeNode sender)
{
	local array<vector> possibles;
	local vector extent;
	local float r, h;
	
	Pawn.GetBoundingCylinder(r, h);
	extent.x = r * 2;
	extent.y = r * 2;
	extent.z = h;

	class'NavigationHandle'.static.GetValidPositionsForBox(Pawn.Location, 2000, extent, true, possibles, , 500);
	
	if (possibles.Length > 0)
		BTAction_NavigateTo(sender).Destination = possibles[Rand(possibles.Length)];
	else
		sender.GotoState('Failed');	
}

function float RadiusBias()
{
	local float bias;

	if (IsAggressive())
		bias -= 0.25;
	else if (IsCautious())
		bias += 0.25;
	else if (IsRetreating())
		bias += 0.5;
			
	return bias;
}

defaultproperties
{
	BotRange=750
	BotFireRange=750
}