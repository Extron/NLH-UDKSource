/*******************************************************************************
	Ab_EarthquakeOuterVolume

	Creation date: 19/06/2013 19:25
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_EarthquakeVolume extends Actor;


var array<ArenaPawn> PawnsInVolume;

/**
 * The earthquake's damage type.
 */
var class<DamageType> DamageType;

var ParticleSystem EarthquakePSTemplate;

var ParticleSystemComponent EarthquakePS;

var AudioComponent EarthquakeSound;

/**
 * The camera shake to play when players are in range.
 */
var CameraShake CShake;

/**
 * Indicates the magnitude of the earthquake.
 */
var float Magnitude;

/**
 * The damage per second that the earthquake does.
 */  
var float DamagePerSecond;

/**
 * The radius of the earthquake volume.
 */
var float Radius;

/**
 * The radius within the earthquake that damage is caused.
 */
var float DamageRadius;

/**
 * Indicates the frequency that the earthquake emits a tremmor.
 */
var float Frequency;

/**
 * A counter for the volume.
 */
var float Counter;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	EarthquakeSound.FadeIn(0.1, 1.0);
	
	EmitEarthquakePS();
}

simulated function Tick(float dt)
{
	local DynamicEnvironmentObject iter;
	local ArenaPawn pawn;
	local vector hitLoc, hitNorm, endLoc, startLoc, forceDir;
	local bool oldCA, oldBA;
	
	super.Tick(dt);
	
	Counter += dt;
	
	foreach CollidingActors(class'Arena.DynamicEnvironmentObject', iter, Radius, Location)
	{
		startLoc = iter.Location;
		endLoc = iter.Location;
		endLoc.z -= (iter.StaticMeshComponent.Bounds.SphereRadius + 5);

		iter.bProjTarget = false;
		oldCA = iter.bCollideActors;
		oldBA = iter.bBlockActors;
		iter.SetCollision(false, false);

	
		if (Landscape(Trace(hitLoc, hitNorm, endLoc, startLoc)) != None)
		{
			forceDir.x = FRand() * (FRand() > 0.5 ? -1 : 1);
			forceDir.y = FRand() * (FRand() > 0.5 ? -1 : 1);
			forceDir.z = 1;
			
			endLoc = hitLoc;
						
			endLoc.x += FRand() * (FRand() > 0.5 ? -1 : 1) * iter.StaticMeshComponent.Bounds.SphereRadius / 2;
			endLoc.y += FRand() * (FRand() > 0.5 ? -1 : 1) * iter.StaticMeshComponent.Bounds.SphereRadius / 2;	
			
			iter.bProjTarget = true;
			iter.SetCollision(oldCA, oldBA);
			
			Trace(hitLoc, hitNorm, endLoc, startLoc);
			
			iter.StaticMeshComponent.AddForce(forceDir * Magnitude * FRand() * 250 * FFloor((Cos(Counter * Frequency) ** 2 + 0.1)), hitLoc);
		}
		else
		{
			iter.bProjTarget = true;
			iter.SetCollision(oldCA, oldBA);
		}
	}
	
	foreach WorldInfo.AllPawns(class'Arena.ArenaPawn', pawn)
	{
		if (VSize(pawn.Location - Location) <= Radius && PawnsInVolume.Find(pawn) == -1)
		{
			PawnsInVolume.AddItem(pawn);
			PawnEnteredVolume(pawn);
		}
		else if (VSize(pawn.Location - Location) > Radius && PawnsInVolume.Find(pawn) != -1)
		{
			PawnsInVolume.RemoveItem(pawn);
			PawnExittedVolume(pawn);
		}
		
		if (VSize(pawn.Location - Location) <= DamageRadius && pawn.Physics == PHYS_Walking)
			pawn.TakeDamage(DamagePerSecond * dt, Instigator.Controller, pawn.Location, vect(0, 0, 0), DamageType);
	}
}

simulated function PawnEnteredVolume(ArenaPawn pawn)
{
	`log(pawn @ "entered volume");
	
	if (PlayerController(pawn.Controller) != None)
		PlayerController(pawn.Controller).ClientPlayCameraShake(CShake);
}

simulated function PawnExittedVolume(ArenaPawn pawn)
{
	`log(pawn @ "exitted volume");
	
	if (PlayerController(pawn.Controller) != None)
		PlayerController(pawn.Controller).ClientStopCameraShake(CShake);
}

simulated event Destroyed()
{
	local ArenaPawn pawn;
	
	super.Destroyed();

	EarthquakeSound.FadeOut(0.1, 0.0);
	
	foreach PawnsInVolume(pawn)
	{
		`log("Volume destroyed with" @ pawn @ "in it");
		if (PlayerController(pawn.Controller) != None)
			PlayerController(pawn.Controller).ClientStopCameraShake(CShake);
	}
}

simulated function EmitEarthquakePS()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && EarthquakePSTemplate != None)
	{
		EarthquakePS = WorldInfo.MyEmitterPool.SpawnEmitter(EarthquakePSTemplate, vect(0, 0, 0));
		EarthquakePS.SetAbsolute(false, false, false);
		EarthquakePS.SetFloatParameter('EarthquakeRadius', DamageRadius);
		EarthquakePS.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		EarthquakePS.bUpdateComponentInTick = true;
		AttachComponent(EarthquakePS);
	}
}

defaultproperties
{
	Begin Object Class=CameraShake Name=CS
		OscillationDuration=0
		OscillationBlendInTime=0.1
		OscillationBlendOutTime=0.1
		AnimBlendInTime=0.1
		AnimBlendOutTime=0.1
		RotOscillation={(Pitch=(Amplitude=150,Frequency=40),
						   Yaw=(Amplitude=150,Frequency=30),
						  Roll=(Amplitude=150,Frequency=60))}
	End Object
	CShake=CS
	
	Begin Object Class=AudioComponent Name=ES
		SoundCue=SoundCue'ArenaAbilities.Audio.EarthquakeSC'
	End Object
	EarthquakeSound=ES
	Components.Add(ES);
	
	EarthquakePSTemplate=ParticleSystem'ArenaAbilities.Particles.EarthquakePS'
	DamageType=class'Arena.Dmg_Earthquake'
	Radius=1024
	DamageRadius=512
	Magnitude=1
	Frequency=15
}