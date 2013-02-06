/*******************************************************************************
	Ab_DeflectionShield

	Creation date: 04/09/2012 12:23
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * An actor used to represent the magnetic deflection shield for the Deflection ability.
 */
class Ab_DeflectionShield extends Actor;

/* The template to use for the particles of the shield. */
var ParticleSystem ShieldTemplate;

/* The shield's particle instance. */
var ParticleSystemComponent Shield;

/** The mesh used to draw the component. */
var() editinline MeshComponent Mesh;

/* This is the angle from the player's viewport that the shield is actually active. */
var float ShieldAngle;

/* The deflection angle of the bullets that hit the shield. */
var float DeflectionAngle;

simulated function PostBeginPlay()
{
	`log("Shield spawned");
	super.PostBeginPlay();
	
	//SetLocation(vect(-96, -1152, 81));
	SetHidden(false);
	Mesh.SetLightEnvironment(ArenaPawn(Instigator).LightEnvironment);
	AttachComponent(Mesh);
	
	EmitShield();
}

simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local vector v, u, newDir;
	local rotator angle;
	local float dProduct;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	
	`log("I was hit by something");
	
	if (RifleBullet(Other) != None)
	{
		`log("Deflecting bullet");
		v = Normal(HitLocation - Location);
		
		if (ArenaPawn(Instigator).Controller != None)
			u = Normal(vect(1, 0, 0) << ArenaPawn(Instigator).Controller.Rotation);
		else
			u = Normal(vect(1, 0, 0) << ArenaPawn(Instigator).Rotation);
		
		`log("U" @ u @ "V" @ v);
		
		dProduct = v dot u;
		
		`log("Dot" @ dProduct @ "Shield Angle" @ Cos(ShieldAngle));
		
		if (dProduct < Cos(ShieldAngle) || Normal(RifleBullet(Other).Velocity) dot -v < 0)
			return;
		
		`log("Deflecting bullet");
		
		angle.Yaw = 2 * (FRand() - 0.5) * DeflectionAngle * RadToUnrRot;
		angle.Pitch = 2 * (FRand() - 0.5) * DeflectionAngle * RadToUnrRot;
		
		`log("Angle" @ angle);
		
		newDir = -Normal(RifleBullet(Other).Velocity) << angle;
		
		`log("Initial dir" @ Normal(RifleBullet(Other).Velocity) @ "New dir" @ newDir);
		
		RifleBullet(Other).Init(newDir);
	}
}

simulated function Tick(float dt)
{
	if (ArenaPawn(Instigator) != None)
	{
		SetLocation(Instigator.Location);
		SetRotation(Instigator.Controller.Rotation);
	}
	
	super.Tick(dt);
}

simulated function bool StopsProjectile(Projectile P)
{
	return false;
}

/**
 * Emits the shield's particle system into the world.
 */
simulated function EmitShield()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ShieldTemplate != None && ArenaPawn(Owner) != None)
	{
		Shield = WorldInfo.MyEmitterPool.SpawnEmitter(ShieldTemplate, vect(0, 0, 0));
		Shield.SetAbsolute(false, false, false);
		Shield.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Shield.bUpdateComponentInTick = true;
		AttachComponent(Shield);
	}
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	
	Begin Object Class=StaticMeshComponent Name=ShieldMesh
		StaticMesh=StaticMesh'ArenaAbilities.Meshes.DeflectionShieldMesh'
		Rotation=(Yaw=-16384,Pitch=16384)
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=false
		bCastDynamicShadow=false
		CastShadow=false
		Scale=3
	End Object
	Mesh=ShieldMesh
	
	ShieldAngle=1.047
	DeflectionAngle=0.262
}