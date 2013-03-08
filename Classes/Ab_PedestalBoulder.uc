/******************************************************************************
	Ab_PedestalBoulder
	
	Creation date: 06/02/2013 22:59
	Copyright (c) 2013, Owner
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_PedestalBoulder extends InterpActor;

/**
 * The float that determines how far in the ground the pedestal starts
 */
var float StartDepth;

/* While rising, the amount it Falls by each step */
var float RiseAmount;

/* The float that determines how much the pedestal Falls the first couple of steps */
var float Rising;
var bool Fall;

/* This is the variable the stores the time before the pedestal disappears */
var float PedestalTimer;

/** The mesh used to draw the component. */
var() editinline MeshComponent Mesh;

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
	
	`log("Rock spawned");
	super.PostBeginPlay();
	
	AttachComponent(Mesh);

	// The below lines makes the pedestal's rotation random
	// newRot = Rotation;      	// Set newRot to our current Rotation
    newRot.Yaw += Rand(65536);	// In the unreal engine, 1 circle = 65536
    SetRotation(newRot);		
	
	if (ArenaPawn(Instigator).Controller != None) {
		// Change to (vect(0, 0, -1)) later
		SetPhysics(PHYS_RigidBody);
		CollisionComponent.SetRBPosition(Instigator.Location + vect(0, 0, 1) * -StartDepth);
		CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
		`log(Instigator.Rotation.Yaw);
		}
	
	RiseAmount = Rising;
	
	SetTimer(PedestalTimer, false, 'FallDown');
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

simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

// When actors that both have
simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	super.Bump(Other, OtherComp, HitNormal);
	
	if (RiseAmount > 0.0 && !Fall && Normal(HitNormal) dot vect(0, 0, 1) > 0.5)
	{
		if (ArenaPawn(Other) != None)
		{
			`log("Hit pawn" @ Other);
		}
	}
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
	//Super.FellOutOfWorld(dmgType);
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bCollideWorld=false
	bNoDelete=false
	//bWorldGeometry=true
	
	Begin Object Class=StaticMeshComponent Name=CubeObject
		StaticMesh=StaticMesh'ArenaTestObjects.Meshes.Cube'
		Scale3D=(X=0.7,Y=0.7,Z=1.4)
	End Object
	Mesh=CubeObject
	Components.Add(CubeObject)
	
	CollisionComponent=CubeObject
	
	Rising = 19.9
	RiseAmount = 0
	StartDepth = 265.0
	PedestalTimer=8.0
	Fall = false;
}