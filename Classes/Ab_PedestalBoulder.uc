/******************************************************************************
	Ab_PedestalBoulder
	
	Creation date: 06/02/2013 22:59
	Copyright (c) 2013, Owner
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_PedestalBoulder extends Actor;

/* While rising, the amount it Falls by each step */
var float RiseAmount;

/* The float that determines how much the pedestal Falls the first couple of steps */
var float Rising;
var bool Fall;

/* This is the variable the stores the time before the pedestal disappears */
var float FallTimer;

/** The mesh used to draw the component. */
var() editinline MeshComponent Mesh;

simulated function PostBeginPlay()
{
	local Rotator newRot;   // This will be our new Rotation

	`log("Rock spawned");
	super.PostBeginPlay();
	
	AttachComponent(Mesh);

	// The below lines makes the pedestal's rotation random
	// newRot = Rotation;      	// Set newRot to our current Rotation
    newRot.Yaw += Rand(65536);	// In the unreal engine, 1 circle = 65536
    SetRotation(newRot);		
	
	RiseAmount = Rising;
	
	SetTimer(FallTimer, false, 'FallDown');
	
	// Non of this works...
	//OnSetVelocity(vect(0.0, 10.0, 0.0));
	Velocity = vect(0.0, 10.0, 0.0);
	Mesh.AddForce(vect(0.0, 1000.0, 0.0));
}

// Have the pedestal Fall until it reaches its correct height
simulated function Tick(float dt)
{
	if ((RiseAmount > 0.0) && (!Fall)) {
		SetLocation(Location + (vect(0, 0, 1) * RiseAmount));
		RiseAmount = RiseAmount - 0.6;
	}
	
	super.Tick(dt);
	
	if (Fall) {
		RiseAmount = RiseAmount + 0.6;
		SetLocation(Location + (vect(0, 0, -1) * RiseAmount));
		if (RiseAmount > Rising) {
			//`log("Pedestal deleted");
			self.Destroy();
		}
	}
}

simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	`log("THE PEDESTAL HAS BEEN TOUCHED");
	`log(Other);
}

// When actors that both have
simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	super.Bump(Other, OtherComp, HitNormal);
	`log("THE PEDESTAL HAS BEEN BUMPED");
	`log(Other);
}


simulated function FallDown() {
	//`log("Pedestal is falling");
	Fall = true;
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true

	Begin Object Class=StaticMeshComponent Name=CubeObject
		StaticMesh=StaticMesh'ArenaTestObjects.Meshes.Cube'
		RBCollideWithChannels=(Untitled3=true,Pawn=true)
		// Below is not being recoginzed by compiler
		//CollisionType=COLLIDE_BlockAll
		Scale3D=(X=0.7,Y=0.7,Z=1.4)
	End Object
	Mesh=CubeObject
	
	// WHY U NO WORK?
	CollisionType=COLLIDE_BlockAll
	//Components.Add(Mesh)
	
	Rising = 19.9
	RiseAmount = 0
	FallTimer=8.0
	Fall = false
}