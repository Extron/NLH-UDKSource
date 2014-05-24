/******************************************************************************
	Ab_PedestalBoulder
	
	Creation date: 06/02/2013 22:59
	Copyright (c) 2014, Strange Box Software
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_PedestalBoulder extends InterpActor;

/**
 * The instance of the ability that generated this pedestal.
 */
var Ab_Pedestal Ability;

/**
 * The particle system for the pillar crumbling effect.
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
var rotator PedestalRotation;

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
	local Rotator newRot;
	
	super.PostBeginPlay();

	if (ArenaPawn(Instigator).Controller != None) 
	{
		SetPhysics(PHYS_RigidBody);	
		
		newRot.Yaw += Rand(65536);
		CollisionComponent.SetRBRotation(newRot);
		CollisionComponent.SetRBPosition(Location);
		CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
		
		PedestalRotation = newRot;
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
			SetTimer(Lifetime, false, 'DestroyPedestal'); 
		}
	}
}

simulated function DestroyPedestal() 
{
	local ParticleSystemComponent Crumble;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && CrumbleTemplate != None)
	{
		Crumble = WorldInfo.MyEmitterPool.SpawnEmitter(CrumbleTemplate, Location, PedestalRotation);
		Crumble.SetAbsolute(false, false, false);
		Crumble.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Crumble.bUpdateComponentInTick = true;
	}
	
	Spawn(class'Arena.PedestalCSV', None, , Location);
	
	if (Ability != None)
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
	
	Begin Object Class=StaticMeshComponent Name=PillarMesh
		StaticMesh=StaticMesh'Solus.Meshes.Pillar'
	End Object
	StaticMeshComponent=PillarMesh
	Components.Add(PillarMesh)
	
	CrumbleTemplate=ParticleSystem'Solus.Particles.PedestalCrumblePS'
	CollisionComponent=PillarMesh
	
	CrumbleSound=SoundCue'Solus.Audio.PedestalCrumbleSC'
	
	RisingTime=2.5
	Lifetime=10
}