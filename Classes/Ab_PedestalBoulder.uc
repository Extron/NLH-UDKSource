/******************************************************************************
	Ab_PedestalBoulder
	
	Creation date: 06/02/2013 22:59
	Copyright (c) 2013, Owner
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_PedestalBoulder extends InterpActor;

/* While rising, the amount it Falls by each step */
var float RiseAmount;

/* The float that determines how much the pedestal Falls the first couple of steps */
var float Rising;
var bool Fall;

/* This is the variable the stores the time before the pedestal disappears */
var float FallTimer;


simulated function Initialize()
{
	SetDrawScale( default.DrawScale );

	ClearTimer('Recycle');
	SetHidden(FALSE);
	StaticMeshComponent.SetHidden(FALSE);
	SetTickIsDisabled(false); 
	SetPhysics(PHYS_RigidBody);
	SetCollision(true, true, true);
}

simulated function PostBeginPlay()
{
	local Rotator newRot;
	
	super.PostBeginPlay();
	

	// The below lines makes the pedestal's rotation random
	// In the unreal engine, 1 circle = 65536
    newRot.Yaw += Rand(65536);
    SetRotation(newRot);		

	if (ArenaPawn(Instigator).Controller != None) 
	{
		SetPhysics(PHYS_RigidBody);
		CollisionComponent.SetRBPosition(Location);
		CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
	}
	
	RiseAmount = Rising;
	
	SetTimer(FallTimer, false, 'FallDown');
}

// Have the pedestal Fall until it reaches its correct height
simulated function Tick(float dt)
{	
	local int direction;
	
	super.Tick(dt);
	
	direction = Fall ? -1 : ((RiseAmount > 0.0) ? 1 : 0);
	
	RiseAmount = RiseAmount - direction * 0.6;
	
	if (RiseAmount <= 0.0)
		SetPhysics(PHYS_None);

	CollisionComponent.SetRBPosition(Location + (vect(0, 0, 1) * RiseAmount * direction));

	if (Fall && RiseAmount > Rising)
			self.Destroy();
}

event bool EncroachingOn(Actor Other)
{
	`log("Encroaching on" @ Other);
	return EncroachingOn(Other);
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
		StaticMesh=StaticMesh'ArenaTestObjects.Meshes.Cube'
		Scale3D=(X=0.7,Y=0.7,Z=1.4)
	End Object
	StaticMeshComponent=CubeObject
	Components.Add(CubeObject)
	
	CollisionComponent=CubeObject
	
	Rising = 19.9
	RiseAmount = 0
	FallTimer=8.0
	Fall = false
}