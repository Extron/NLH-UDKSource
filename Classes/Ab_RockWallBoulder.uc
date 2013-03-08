/******************************************************************************
	Ab_RockWallBoulder
	
	Creation date: 13/02/2013 14:19
	Copyright (c) 2013, Owner
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWallBoulder extends KActor;

/* While rising, the amount it Falls by each step */
var float RiseAmount;

/* The float that determines how much the pedestal Falls the first couple of steps */
var float Rising;

/* Becomes true once the wall starts falling */
var bool Fall;

/* This is the variable the stores the time before the pedestal disappears */
var float FallTimer;

/** The mesh used to draw the component. */
var() editinline MeshComponent Mesh;

simulated function PostBeginPlay()
{
	CollisionComponent = Mesh;
	
	`log("Rock wall spawned.");
	
	SetPhysics(PHYS_RigidBody);
	AttachComponent(Mesh);
	 
	SetRotation(Instigator.Rotation);
	
	RiseAmount = Rising;
	
	SetTimer(FallTimer, false, 'FallDown');
	
	// None of these works... :(
	// OnSetVelocity(vect(0.0, 10.0, 0.0));
	// Velocity = vect(0.0, 1000.0, 0.0);
	// Mesh.AddForce(vect(0.0, 1000.0, 0.0));
	// ApplyImpulse(vect(0.0, 1.0, 0.0), 1.0, Location);
	
	super.PostBeginPlay();
}

// Have the pedestal Fall until it reaches its correct height
simulated function Tick(float dt)
{
	if (Fall) {
		RiseAmount = RiseAmount + 0.5;
		SetLocation(Location + (vect(0, 0, -1) * RiseAmount));
		if (RiseAmount > Rising) {
			//`log("Rock wall deleted");
			self.Destroy();
		}
	}
	
	else if (RiseAmount > 0.0) {
		SetLocation(Location + (vect(0, 0, 1) * RiseAmount));
		RiseAmount = RiseAmount - 1.0;
	}
	
	super.Tick(dt);
}

simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	`log("THE ROCK WALL HAS BEEN TOUCHED");
	`log(Other);
}

// When actors that both have
simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	// Enemies take damage if they are hit while the wall is rising
	//if (RiseAmount > 0.0) {
		// To do: fix so that the enemy gets knocked up (and reduce damage) & FIX
		Other.TakeDamage(2000.0, Instigator.Controller, HitNormal, Velocity, class'DamageType');
		// class'AbilityDamageType' ???
	//}
	
	super.Bump(Other, OtherComp, HitNormal);
	`log("THE ROCK WALL HAS BEEN BUMPED");
	`log(Other);
}


simulated function FallDown() {
	//`log("Rock wall is falling");
	Fall = true;
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true

	Begin Object Class=StaticMeshComponent Name=CubeObject
		StaticMesh=StaticMesh'ArenaTestObjects.Meshes.Cube'
		// Below is not being recoginzed by compiler
		//CollisionType=COLLIDE_BlockAll
		Scale3D=(X=0.45,Y=2.9,Z=1.0)
	End Object
	Mesh=CubeObject
	
	// WHY U NO WORK?
	// CollisionType=COLLIDE_BlockAll
	bStatic = false
	bNoDelete = false
	bGameRelevant = true
	bOnlyOwnerSee = false
	//Components.Add(Mesh)
	
	// COLLIDE_BlockAll = true
	// COLLIDE_TouchAll = true
	
	Rising = 24.0
	RiseAmount = 0
	FallTimer=8.0
	Fall = false
}