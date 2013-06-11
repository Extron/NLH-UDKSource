/******************************************************************************
	Ab_WallLaunchBoulder
	
	Creation date: 09/01/2013 16:43
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
	
	TODO:
	
	Needs melee code to set Launching.
******************************************************************************/

class Ab_WallLaunchBoulder extends Ab_PortableShieldBoulder;

/* The distance the wall will launch per tick */
var float LaunchDist;

/* How long the wall will launch */
var float LaunchTimer;

/* Bool the determines if the wall is being moved by the player. (Currently
always on) */
var bool Launching;

/* The direction in which the rock wall should travel. */
var Rotator LaunchDirection;

// Needs melee code to call this function
simulated function LaunchWall() {
	Launching = true;
	LaunchDirection = Instigator.Rotation;
	
	SetTimer(LaunchTimer, false, 'StopLaunch');
}

simulated function StopLaunch() {
	Launching = false;
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
		
	if (Launching) {
		CollisionComponent.SetRBPosition(Location + ((vect(0, 1, 0) * LaunchDist) << LaunchDirection));
	}
	else if ((direction != -1) && Moving) {
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
	LaunchDist=0.5
	LaunchTimer=9
}