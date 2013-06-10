/******************************************************************************
	Ab_PortableShieldBoulder
	
	Creation date: 19/05/2013 21:38
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
	
	TODO:
	
	Needs to active & deactivate with melee code.
******************************************************************************/

class Ab_PortableShieldBoulder extends Ab_RockWallBoulder;

/* The distance away from the player while being moved. (I presume we do not
want this to vary?) */
var float MovingDistance;

/* Bool the determines if the wall is being moved by the player. (Currently
always on) */
var bool Moving;

/* PlayerStatsModifier for altering player movement & looking speed. */
var PlayerStatModifier playerStatMod;

/* Player movement slow while carrying */
var float MoveReduction;

simulated function Initialize()
{
	PlayerStatMod.ValueMods[PSVMobility] = MoveReduction;

	ArenaPawn(Instigator).Stats.AddModifier(PlayerStatMod);
	
	super.Initialize();
}

simulated function Tick(float dt)
{
	local int direction;
	
	// Needed?
	super.Tick(dt);
	
	direction = Fall ? -1 : ((RiseAmount > 0.0) ? 1 : 0);

	RiseAmount = RiseAmount - direction * MoveAmount;
	
	if (RiseAmount <= 0.0)
		SetPhysics(PHYS_None);

	if ((direction != -1) && Moving) {
		CollisionComponent.SetRBPosition((vect(1, 0, 0) * MovingDistance) << Instigator.Rotation);
		CollisionComponent.SetRBRotation(Instigator.Rotation);
	}
	else if (direction != -1) {
		CollisionComponent.SetRBPosition(Location + (vect(0, 0, 1) * RiseAmount * direction));
	}
	
	if (Fall && RiseAmount > Rising)
		self.Destroy();
}

defaultproperties
{
	MovingDistance = 5
	Moving = true
	
		Begin Object Class=PlayerStatModifier Name=NewMod
	End Object
	playerStatMod=NewMod
	
	MoveReduction = 0.5;
}