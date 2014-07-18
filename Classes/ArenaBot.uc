/*******************************************************************************
	ArenaBot

	Creation date: 15/10/2012 08:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaBot extends UDKBot
	dependson(BehaviorTreeNode);


struct MoveTowardParameters
{
	var Actor Target;
	var Actor Focus;
	var float DestinationOffset;
	var bool CanStrafe;
	var bool ShouldWalk;
};

struct MoveToParameters
{
	var vector Destination;
	var Actor Focus;
	var float DestinationOffset;
	var bool ShouldWalk;
};


/**
 * The bot's personality, which governs much of how the bot responds to events in a level.
 */
var BotPersonality Personality;

var MoveTowardParameters MTParams;

var MoveToParameters MParams;

/**
 * The last location that the bot was in good condition at.
 */
var vector LastStableLocation;

/**
 * The location that the bot last saw its target.
 */
var vector LastSeenLocation;

/**
 * The direction that the target was travelling in when it was last seen.
 */
var vector LastSeenDirection;

/**
 * The direction the bot is evading in.
 */
var vector EvadeDirection;

/**
 * The actor that most recently attacked the bot.
 */
var Actor Attacker;

/**
 * The root node of the behavior tree for this bot.
 */
var BehaviorTreeNode BTRoot;

/**
 * The current node depending on a latent process in ArenaBot.
 */
var BehaviorTreeNode CurrentLatentNode;

/**
 * The last navigation point that the AI is or was wandering to.
 */
var NavigationPoint WanderTarget;

/**
 * The current destination of the bot.  This is set by various BT nodes, and should not be changed during runtime.
 */
var vector Destination;

/**
 * The source code for the bot's behavior tree.
 */
var string BTSource;


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
 * The minimum amount of time that the bot needs to use an ability again.
 */
var float UseAbIntervalMin;

/**
 * The maximum amount of time that the bot needs to use an ability again.
 */
var float UseAbIntervalMax;

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
 * Indicates that the bot can use an ability.
 */
var bool CanUseAbility;

/**
 * Indicates that the bot should be searching for its target.
 */
var bool Searching;

/**
 * A boolean that indicates that the bot was recently shot at.
 */
var bool WasShotAt;

var bool WasHit;


event Tick(float dt)
{
	super.Tick(dt);
	
	LastShotAtDuration += dt;

	if (BTRoot != None)
		BTRoot.Update(dt);
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	PlayerReplicationInfo = spawn(class'Arena.ArenaPRI', self);
	Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
	Pawn.SetMovementPhysics();
	
	LastShotAtDuration = 0;
	
	ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn));
	ArenaWeapon(ArenaPawn(Pawn).Weapon).InitializeStats();
	
	BTRoot = ParseTree(BTSource);
	
	if (BTRoot != None)
		BTRoot.SetController(self);
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local vector dir;
	
	super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
		
	WasHit = true;
	
	if (InstigatedBy == None)
	{
		`log(self @ "NotifyTakeHit contained a null instigator for" @ damageType);
		return;
	}
	
	if (!IsAggressive() && LastShotAtDuration < 5 && Pawn.Health < ArenaPawn(Pawn).HealthMax * 0.85 && FRand() > 0.5)
	{
		dir.x = FRand() * 2 - 1;
		dir.y = FRand() * 2 - 1;
		dir.z = FRand() * 2 - 1;

		ShotAt(ArenaWeapon(InstigatedBy.Pawn.Weapon), InstigatedBy.Pawn, dir, Normal(Pawn.Location - InstigatedBy.Pawn.Location));
	}
}

function NotifyKilled(Controller killer, Controller killed, Pawn killedPawn, class<DamageType> damageType)
{
	super.NotifyKilled(killer, killed, killedPawn, damageType);
	
	if (killed == self)
	{
		if (ArenaTeamInfo(PlayerReplicationInfo.Team) != None)
			ArenaTeamInfo(PlayerReplicationInfo.Team).TeamMemberKilled(self);
			
		BTRoot.DestroyTree();
	}
}

/**
 * This function allows a bot's behavior tree to be overridden at any time, allowing its behaviors to be modified during runtime.
 */
simulated function SetBehaviorTree(BehaviorTreeNode rootNode)
{
	BTRoot.DestroyTree();
	BTRoot = rootNode;
	
	if (BTRoot != None)
		BTRoot.SetController(self);
}

/**
 * Parses the bot's behavior tree source and creates the corresponding behavior tree.
 */
function BehaviorTreeNode ParseTree(string tree)
{
	local array<string> params;
	local array<string> subtrees;
	local array<string> delBinding;
	
	local string header;
	local string body;
	local string footer;
	local BehaviorTreeNode node;
	local class<BehaviorTreeNode> nodeClass;
	local int i;
	
	node = None;
	
	header = tree;
	
	body = Split(header, ">", true);
	header = Repl(header, body, "");
	header = Repl(Repl(header, ">", ""), "<", "");
	
	params = SplitString(header, " ", true);
	
	if (params.Length > 0)
	{
		footer = SplitLast(body, "</" $ params[0] $ ">");
		body = Left(body, Len(body) - Len(footer));
		
		subtrees = SplitBody(body);
		
		nodeClass = class<BehaviorTreeNode>(DynamicLoadObject("Arena." $ params[0], class'class'));
		
		if (nodeClass != None)
		{
			node = Spawn(nodeClass, None);
		
			params.Remove(0, 1);

			node.SetParameters(params);
			
			for (i = 0; i < params.Length; i++)
			{
				delBinding = SplitString(params[i], "=", true);
				
				if (delBinding.Length == 2 && node.HasDelegate(delBinding[0]))
					AssignNodeDelegate(node, delBinding[0], delBinding[1]);
			}
			
			for (i = 0; i < subtrees.Length; i++)
				BTSelector(node).AddChild(ParseTree(subtrees[i]));
		}
	}
	
	return node;
}

function array<string> SplitBody(string body)
{
	local array<string> subtrees;
	local int scope;
	local int i, prev;
	
	prev = 0;
	
	for (i = 0; i < Len(body); i++)
	{			
		if (i + 1 == Len(body))
		{
			subtrees.AddItem(Mid(body, prev, i - prev + 1));
		}
		else if (Mid(body, i, 1) == "<" && Mid(body, i + 1, 1) != "/")
		{
			scope++;
		}
		else if (Mid(body, i, 2) == "</")
		{
			scope--;
		}
		else if (Mid(body, i, 1) == "," && scope == 0)
		{
			subtrees.AddItem(Mid(body, prev, i - prev));
			prev = i + 1;
		}
	}
	
	return subtrees;
}

function string SplitLast(string str, string substr)
{
	local int i;
	
	if (Len(str) < Len(substr))
		return "";
		
	for (i = Len(str) - Len(substr); i >= 0; i--)
	{
		if (Mid(str, i, Len(substr)) == substr)
			return Right(str, Len(str) - i);
	}
	
	return "";
}

/**
 * Assigns a function within this class to a specified delegate in a BT node.  This should be implemented per each child class
 * that requires a specific behavior tree.
 */
event AssignNodeDelegate(BehaviorTreeNode node, string delegateTarget, string funcName)
{
}

event BeginMoveToward(BehaviorTreeNode node, Actor target, Actor viewFocus, float offset, bool canStrafe, bool shouldWalk)
{
	//We don't want to short circuit any states that may be running latent code, so if we are not in the default state, don't attempt to 
	//change the state.
	if (CurrentLatentNode != None && CurrentLatentNode != node)
		return;
		
	MTParams.Target = target;
	MTParams.Focus = viewFocus;
	MTParams.DestinationOffset = offset;
	MTParams.CanStrafe = canStrafe;
	MTParams.ShouldWalk = shouldWalk;
	
	CurrentLatentNode = node;
	
	GotoState('MoveTowardState');
}

event BeginMoveTo(BehaviorTreeNode node, vector dest, Actor viewFocus, float offset, bool shouldWalk)
{
	//We don't want to short circuit any states that may be running latent code, so if we are not in the default state, don't attempt to 
	//change the state.
	if (CurrentLatentNode != None && CurrentLatentNode != node)
		return;
		
	MParams.Destination = dest;
	MParams.Focus = viewFocus;
	MParams.DestinationOffset = offset;
	MParams.ShouldWalk = shouldWalk;
	
	CurrentLatentNode = node;
	
	GotoState('MoveToState');
}

event BeginFinishRotation(BehaviorTreeNode node)
{
	if (CurrentLatentNode != None && CurrentLatentNode != node)
		return;
		
	CurrentLatentNode = node;
	
	GotoState('FinishRotationState');
}

event MoveTowardFocus(BehaviorTreeNode sender)
{
	BTAction_MoveToward(sender).Target = Focus;
	BTAction_MoveToward(sender).DestinationOffset = BotRange;
}

function name GetAttack(Actor actor)
{
	if (AP_Bot(Pawn).HasAbility(ArenaPawn(Focus)) && CanUseAbility && FRand() > 0.75)
		return 'UsingAbility';
	else if (ArenaWeapon(Pawn.Weapon) != None && VSize(Pawn.Location - Focus.Location) < ArenaWeapon(Pawn.Weapon).GetIdealRange())
		return 'FiringWeapon';
	else
		return 'MoveToTarget';
}

function ShotAt(ArenaWeapon weap, Actor shooter, vector traceLoc, vector direction)
{
	LastShotAtDuration = 0;
	EvadeDirection = traceLoc - Pawn.Location;
	Attacker = shooter;
	
	WasShotAt = true;
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
		if (Pawn.Health > 0)
			cautionMeasure += 0.5 * Pawn.HealthMax / float(Pawn.Health);
		
		if (ArenaPawn(Focus).Health > 0)
			cautionMeasure -= 0.5 * ArenaPawn(Focus).HealthMax / float(ArenaPawn(Focus).Health);
		
		//Reduce the need for caution for every near friendly bot within 50 units.
		cautionMeasure -= BotsNear(50) * 0.5;
		
		cautionMeasure -= LastShotAtDuration * 0.15;
	}
	
	cautionMeasure += Personality.Cowardice * 0.25;
	
	//if (cautionMeasure > 0.0)
		//`log("Bot" @ self @ "is cautious.");
		
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
	
	aggresionMeasure += Personality.Aggression;
	
	//if (aggresionMeasure > 0.0)
		//`log("Bot" @ self @ "is aggresive.");
		
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
	
	retreatMeasure += Personality.Cowardice - Personality.Bravery;
	
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
		if (b.Health > 0)
		{
			if (Pawn.GetTeam().TeamIndex == b.GetTeam().TeamIndex)
				count++;
		}
	}
	
	return count;
}

auto state Idle
{
	event Tick(float dt)
	{
		global.Tick(dt);	
	}
	
Begin:
	if (Pawn != None)
		Pawn.GotoState('Idle');
		
	CurrentLatentNode = None;
}

simulated state MoveTowardState
{
Begin:
	if (Pawn != None)
		Pawn.GotoState('MoveTowardState');
		
	MoveToward(MTParams.Target, MTParams.Focus, MTParams.DestinationOffset, MTParams.CanStrafe, MTParams.ShouldWalk);
	GotoState('Idle');
}

simulated state MoveToState
{
Begin:
	if (Pawn != None)
		Pawn.GotoState('MoveToState');
		
	MoveTo(MParams.Destination, MParams.Focus, MParams.DestinationOffset, MParams.ShouldWalk);
	GotoState('Idle');
}

simulated state FinishRotationState
{
Begin:
	if (Pawn != None)
		Pawn.GotoState('FinishRotationState');
		
	FinishRotation();
	GotoState('Idle');
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

defaultproperties
{
	Begin Object Class=BotPersonality Name=BP
	End Object
	Personality=BP
	
	BTSource="<BTAction_Idle></BTAction_Idle>"
	
	BotRange=1000
	BotFireRange=1000
	FireIntervalMax=2.5
	FireIntervalMin=0.25
	UseAbIntervalMax=15
	UseAbIntervalMin=5
	CanFire=true
	CanUseAbility=true
}