/*******************************************************************************
	Bot_Orb

	Creation date: 03/03/2013 03:53
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Bot_Orb extends ArenaBot;

var BTAction_Condition EvadeCondition;

event PostBeginPlay()
{
	super.PostBeginPlay();
	
	BTSource = 	"<BTSelector_Repeater>" $ 
					"<BTSelector_Priority>" $ 
						"<BTSelector_Sequence>" $
							"<BTAction_Condition ID=EvadeCondition></BTAction_Condition>," $
							"<BTAction_Orbit ZenithMin=0.7853981 ZenithMax=2.3561944 RadialMin=200 RadialMax=1000 OnRunning=Evade></BTAction_Orbit>" $
						"</BTSelector_Sequence>," $
						"<BTSelector_Concurrent>" $
							"<BTAction_InRange Range=" $ BotRange $ " OnRunning=InRangeFocus></BTAction_InRange>," $
							"<BTSelector_Random>" $
								"<BTAction_Orbit ZenithMin=0.7853981 ZenithMax=2.3561944 RadialMin=200 RadialMax=1000 OnRunning=Orbit></BTAction_Orbit>," $
								"<BTAction_Idle OnRunning=Idle NodeBias=2></BTAction_Idle>" $
							"</BTSelector_Random>," $
							"<BTSelector_Repeater>" $ 
								"<BTSelector_Delayer Delay=" $ Lerp(FireIntervalMin, FireIntervalMax, FRand()) $ " OnSucceeded=DelayFire>" $
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
							"<BTAction_Idle OnRunning=Idle></BTAction_Idle>," $
							"<BTAction_NavigateTo OnRunning=Search></BTAction_NavigateTo>," $
							"<BTSelector_Repeater Repetitions=3>" $
								"<BTSelector_Sequence>" $
									"<BTAction_Idle OnRunning=Idle></BTAction_Idle>," $
									"<BTAction_NavigateTo OnRunning=MoveToRandom></BTAction_NavigateTo>" $
								"</BTSelector_Sequence>" $
							"</BTSelector_Repeater>" $
						"</BTSelector_Sequence>," $
						"<BTSelector_Sequence>" $
							"<BTSelector_Repeater>" $
								"<BTSelector_Sequence>" $
									"<BTAction_Idle OnRunning=Idle></BTAction_Idle>," $
									"<BTAction_NavigateTo OnRunning=MoveToRandom></BTAction_NavigateTo>" $
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
	if (funcName == "Orbit" && delegateTarget == "OnRunning")
		node.OnRunning = Orbit;
	
	if (funcName == "Idle" && delegateTarget == "OnRunning")
		node.OnRunning = Idle;
	
	if (funcName == "DelayFire" && delegateTarget == "OnSucceeded")
		node.OnSucceeded = DelayFire;
		
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
}

event Orbit(BehaviorTreeNode sender)
{
	local float speedMin, speedMax;
	
	speedMin = 100;
	speedMax = 500;
	
	BTAction_Orbit(sender).AzimuthDirection = FRand() >= 0.5 ? (FRand() >= 0.5 ? 1 : -1) : 0;
	BTAction_Orbit(sender).ZenithDirection = FRand() >= 0.5 ? (FRand() >= 0.25 ? 1 : -1) : 0;
	BTAction_Orbit(sender).RadialDirection = FRand() >= 0.5 - Abs(RadiusBias()) ? (FRand() >= 0.5 + RadiusBias() ? 1 : -1) : 0;

	BTAction_Orbit(sender).AzimuthSpeed = Lerp(speedMin, speedMax, FRand());
	BTAction_Orbit(sender).ZenithSpeed = Lerp(speedMin, speedMax, FRand());
	BTAction_Orbit(sender).RadialSpeed = Lerp(speedMin, speedMax, FRand())  * (1 + Abs(RadiusBias()) * 4);
	
	BTAction_Orbit(sender).OrbitTime = Lerp(0.25, 1.5, FRand());
}

event Evade(BehaviorTreeNode sender)
{
	local float speedMin, speedMax;
	
	if (Attacker != None)
	{
		Focus = Attacker;
		
		speedMin = 100;
		speedMax = 500;
		
		if (EvadeDirection dot ((Pawn.Location - Focus.Location) cross vect(0, 0, 1)) >= 0)
			BTAction_Orbit(sender).AzimuthDirection = -1;
		else
			BTAction_Orbit(sender).AzimuthDirection = 1;

		if (EvadeDirection dot vect(0, 0, 1) >= 0)
			BTAction_Orbit(sender).ZenithDirection = 1;
		else
			BTAction_Orbit(sender).ZenithDirection = -1;

			
		BTAction_Orbit(sender).AzimuthDirection = FRand() >= 0.5 ? (FRand() >= 0.5 ? 1 : -1) : 0;
		BTAction_Orbit(sender).ZenithDirection = FRand() >= 0.5 ? (FRand() >= 0.25 ? 1 : -1) : 0;
		BTAction_Orbit(sender).RadialDirection = 0;

		BTAction_Orbit(sender).AzimuthSpeed = Lerp(speedMin, speedMax, FRand()) * 5;
		BTAction_Orbit(sender).ZenithSpeed = Lerp(speedMin, speedMax, FRand()) * 5;
		BTAction_Orbit(sender).RadialSpeed = 0;
		
		BTAction_Orbit(sender).OrbitTime = Lerp(0.25, 1.5, FRand()) * 0.5;
	}
	else
	{
		sender.GotoState('Failed');
	}
}

event Idle(BehaviorTreeNode sender)
{
	BTAction_Idle(sender).Duration = Lerp(0.25, 1.5, FRand());
}

event DelayFire(BehaviorTreeNode sender)
{
	BTSelector_Delayer(sender).Delay = Lerp(FireIntervalMin, FireIntervalMax, FRand());
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

event NavGoalsRandom(NavigationHandle handle)
{
	class'NavMeshPath_WithinTraversalDist'.static.DontExceedMaxDist(handle, 2000, true);
	class'NavMeshGoal_Random'.static.FindRandom(handle, 500, 25);
}

event MoveToRandom(BehaviorTreeNode sender)
{
	local array<vector> possibles;
	local box bb;
	
	Pawn.GetComponentsBoundingBox(bb);
	
	class'NavigationHandle'.static.GetValidPositionsForBox(Pawn.Location, 5000, bb.Max, true, possibles, , 500);
	
	`log("Found" @ possibles.Length @ "random positions to try");
	
	BTAction_NavigateTo(sender).Destination = possibles[Rand(possibles.Length)];
	
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