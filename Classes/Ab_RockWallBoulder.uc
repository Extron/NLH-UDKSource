/******************************************************************************
	Ab_RockWallBoulder
	
	Creation date: 13/02/2013 14:19
	Copyright (c) 2013, Strange Box Software
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWallBoulder extends InterpActor;

/**
 * The instance of the ability that generated this rock wall.
 */
var Ab_RockWall Ability;

/**
 * The particle system for the rock wall crumbling effect.
 */
var ParticleSystem CrumbleTemplate;

/**
 * The sound cue to play when crumbling.
 */
var SoundCue CrumbleSound;

/**
 * The starting location of the pedestal.
 */
var vector StartLocation;

/**
 * The ending location of the pedestal.
 */
var vector EndLocation;

/**
 * The rotation of the pedestal object.
 */
var rotator WallRotation;

/**
 * Stores how fast the pillar rised from its start depth to its full height.
 */
var float RisingTime;

/**
 * The duration that the pillar exists for.
 */
var float Lifetime;

/**
 * The current internal time of the pedestal.
 */
var float Timer;


simulated function Initialize()
{
	ClearTimer('Recycle');
	SetHidden(FALSE);
	StaticMeshComponent.SetHidden(FALSE);
	SetTickIsDisabled(false); 
	SetPhysics(PHYS_RigidBody);
	SetCollision(true, true, true);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (ArenaPawn(Instigator).Controller != None) 
	{
		SetPhysics(PHYS_RigidBody);
		CollisionComponent.SetRBPosition(Location);
		CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
		CollisionComponent.SetRBRotation(Instigator.Rotation);
		WallRotation = Instigator.Rotation;
	}
}

simulated function Tick(float dt)
{
	local float z;
	
	super.Tick(dt);
	
	if (Timer < RisingTime)
	{
		z = Lerp(StartLocation.z, EndLocation.z, Timer / RisingTime);	
		CollisionComponent.SetRBPosition(Location * vect(1, 1, 0) + vect(0, 0, 1) * z);
		Timer += dt;
		
		if (Timer > RisingTime)
		{
			SetPhysics(PHYS_None);
			SetTimer(Lifetime, false, 'DestroyRockWall'); 
		}
	}
}

simulated function Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	if (Timer < RisingTime) 
		Other.TakeDamage(2000.0, Instigator.Controller, HitNormal, Velocity, class'DamageType');
	
	super.Bump(Other, OtherComp, HitNormal);
}


simulated function DestroyRockWall() 
{
	local ParticleSystemComponent Crumble;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && CrumbleTemplate != None)
	{
		Crumble = WorldInfo.MyEmitterPool.SpawnEmitter(CrumbleTemplate, Location, WallRotation);
		Crumble.SetAbsolute(false, false, false);
		Crumble.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Crumble.bUpdateComponentInTick = true;
	}
	
	//Spawn(class'Arena.PedestalCSV', None, , Location);
	
	if (Ability != None && CrumbleSound != None)
		Ability.AbilityPlaySound(CrumbleSound);
		
	Destroy();
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
	
	CrumbleTemplate=ParticleSystem'Solus.Particles.RockWallCrumblePS'

	Begin Object Class=StaticMeshComponent Name=RockWallMesh
		StaticMesh=StaticMesh'Solus.Meshes.RockWall'
	End Object
	StaticMeshComponent=RockWallMesh
	Components.Add(RockWallMesh)
	
	CollisionComponent=RockWallMesh
	
	RisingTime=0.15
	Lifetime=15
}