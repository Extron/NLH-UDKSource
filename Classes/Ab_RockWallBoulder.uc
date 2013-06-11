/******************************************************************************
	Ab_RockWallBoulder
	
	Creation date: 13/02/2013 14:19
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWallBoulder extends InterpActor;

/* While rising, the amount it Falls by each step */
var float RiseAmount;

/* The float that determines how much the pedestal Falls the first couple of steps */
var float Rising;

/* Becomes true once the wall starts falling */
var bool Fall;

/* This is the variable the stores the time before the pedestal disappears */
var float FallTimer;

// Determines the rate of falling/rising
var float MoveAmount;

simulated function Initialize()
{
	// SetDrawScale( default.DrawScale );
	SetDrawScale3D( vect(3.0, 3.0, 3.0) );

	ClearTimer('Recycle');
	SetHidden(FALSE);
	StaticMeshComponent.SetHidden(FALSE);
	SetTickIsDisabled(false); 
	SetPhysics(PHYS_RigidBody);
	SetCollision(true, true, true);
}

simulated function PostBeginPlay()
{
	`log("Rock wall spawned.");	
	super.PostBeginPlay();
	
	if (ArenaPawn(Instigator).Controller != None) 
	{
		SetPhysics(PHYS_RigidBody);
		CollisionComponent.SetRBPosition(Location);
		CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
		CollisionComponent.SetRBRotation(Instigator.Rotation);
	}
	
	RiseAmount = Rising;
	
	SetTimer(FallTimer, false, 'FallDown');
}

// Have the rock wall rise/fall until it reaches its correct height
simulated function Tick(float dt)
{
	local int direction;
	
	super.Tick(dt);
	
	direction = Fall ? -1 : ((RiseAmount > 0.0) ? 1 : 0);

	RiseAmount = RiseAmount - direction * MoveAmount;
	
	if (RiseAmount <= 0.0)
		SetPhysics(PHYS_None);

	CollisionComponent.SetRBPosition(Location + (vect(0, 0, 1) * RiseAmount * direction));
	
	if (Fall && RiseAmount > Rising)
		self.Destroy();
}

// When actors that both have
simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	// Enemies take damage if they are hit while the wall is rising
	if (RiseAmount > 0.0) {
		// To do: fix so that the enemy gets knocked up (and reduce damage) & FIX
		Other.TakeDamage(2000.0, Instigator.Controller, HitNormal, Velocity, class'DamageType');
	}
	
	super.Bump(Other, OtherComp, HitNormal);
	//`log("THE ROCK WALL HAS BEEN BUMPED: " @ Other);
}


simulated function FallDown() 
{
	Fall = true;
	SetPhysics(PHYS_RigidBody);
}

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
	//Normally, when a physics actor falls out of the world, it is automatically destroyed.  Here, we override to 
	//prevent that, as we spawn the actor beneath the world.
	//Super.FellOutOfWorld(dmgType);
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bCollideWorld=false
	bNoDelete=false
	
	Begin Object Class=StaticMeshComponent Name=CubeObject
		StaticMesh=StaticMesh'ArenaAbilities.Meshes.RockWallMesh'
	End Object
	StaticMeshComponent=CubeObject
	Components.Add(CubeObject)
	
	CollisionComponent=CubeObject
	
	Rising=40
	RiseAmount = 0
	FallTimer=8.0
	Fall = false
	MoveAmount=4.8
}