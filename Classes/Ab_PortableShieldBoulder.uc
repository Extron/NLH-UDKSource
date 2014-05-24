/******************************************************************************
	Ab_PortableShieldBoulder
	
	Creation date: 19/05/2013 21:38
	Copyright (c) 2014, Strange Box Software
******************************************************************************/

class Ab_PortableShieldBoulder extends Ab_RockWallBoulder implements (IInteractiveObject);


/**
 * Alters the player's stats while they are holding the wall.
 */
var PlayerStatModifier StatMod;

/**
 * The displacement vector of the wall from the moving pawn when it is being grabbed.
 */
var vector Displacement;

/**
 * The initial rotation of the rock wall before being grabbed.
 */
var rotator FixedRotation;

/**
 * The maximum distance the wall can shift up or down from the player's position while moving.
 */
var float MaxHeightDisplacement;

/**
 * The radius of area around the rock wall which cannot collide with things while moving.
 */
var float CollisionRadius;

/**
 * The radius within which the player can grab the wall.
 */
var float InteractionRadius;


simulated function bool IsPlayerNear(Pawn user)
{
	return user == Instigator && VSize(Location - user.Location) <= InteractionRadius && user.Controller.LineOfSightTo(self);
}

simulated function InteractWith(Pawn pawn)
{
	`log(self @ "Interacting with" @ pawn);
	
	GrabWall();
}

/**
 * This is called when the pawn releases the interaction button.
 */
simulated function Release(Pawn pawn)
{
	ReleaseWall();
}

/**
 * Gets the message the interactive object displays to the HUD when the player is near.
 */
simulated function string GetMessage()
{
	return "Hold <use> to grab wall";
}

/**
 * Indicates whether the interactive object requires the player to hold down the use button to continue interacting with it.
 */
simulated function bool MustHold()
{
	return true;
}

/**
 * Gets the length the player must hold down the use button for before the object is activated.
 */
simulated function float GetTriggerDuration()
{
	return 1.0;
}

/**
 * Gets the distance from the object to a specified actor.
 */
simulated function float GetDistanceFrom(Actor actor)
{
	return VSize(Location - actor.Location);
}

simulated function GrabWall()
{
	Displacement = (Location - Instigator.Location) << Instigator.Rotation;
	FixedRotation = Rotation;
	ArenaPawn(Instigator).AddStatMod(StatMod);
	
	SetPhysics(PHYS_RigidBody);
	CollisionComponent.SetRBPosition(Location);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
	CollisionComponent.SetRBRotation(Rotation);
	
	GotoState('Moving');
}

simulated function ReleaseWall()
{
	ArenaPawn(Instigator).RemoveStatMod(StatMod);
	SetPhysics(PHYS_None);
	GotoState('Fixed');
}

auto state Fixed
{
	simulated function Tick(float dt)
	{
		super.Tick(dt);

		if (IsPlayerNear(Instigator))
			ArenaPawn(Instigator).SetNearestInterObj(self);
	}
}

state Moving
{
	simulated function Tick(float dt)
	{
		local vector newLoc;
		local rotator newRot;
		local vector traceLoc, traceNorm;
		local TraceHitInfo info;
		//local Actor iter;
		local bool canMove;
		
		super.Tick(dt);

		
		newLoc = Instigator.Location + (Displacement >> Instigator.Rotation);
		newRot = Rotation + Instigator.Rotation;
				
		`log("Moving rock wall" @ newLoc @ Displacement);
		
		if (Trace(traceLoc, traceNorm, newLoc + vect(0, 0 , 1) * MaxHeightDisplacement, newLoc - vect(0, 0 , 1) * MaxHeightDisplacement, false, , info) != None)
		{
			`log("Trace returned something");
			
			if (ArenaPMP(info.PhysMaterial.PhysicalMaterialProperty) != None && ArenaPMP(info.PhysMaterial.PhysicalMaterialProperty).HasProperty("Rocky"))
			{
				`log("Traced mat is rocky");
				
				newLoc.z = traceLoc.z;
				
				canMove = true;
				
				/**
				foreach CollidingActors(class'Actor', iter, CollisionRadius, newLoc)
				{
					`log("Collided with" @ iter);
					canMove = false;
					break;
				}*/
				
				if (canMove)
				{
					`log("Can move rock wall");
					CollisionComponent.SetRBPosition(newLoc);
					CollisionComponent.SetRBRotation(newRot);
					
					return;
				}
			}			
		}
		
		CollisionComponent.SetRBPosition(Location);
		CollisionComponent.SetRBRotation(Rotation);
	}
}

defaultproperties
{	
	Begin Object Class=PlayerStatModifier Name=NewMod
	End Object
	StatMod=NewMod
	
	InteractionRadius=196
	CollisionRadius=256
	MaxHeightDisplacement=128
}