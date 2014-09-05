/*******************************************************************************
	Explosion

	Creation date: 18/08/2014 19:25
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Explosion extends Actor;

/**
 * The damage type of the explosion.
 */
var class<DamageType> DamageType;

/**
 * The light to spawn upon explosion.
 */
var class<UDKExplosionLight> Light;

/**
 * The explosion particle system template.
 */
var ParticleSystem ExplosionTemplate;

/**
 * The actual explosion particle system.
 */
var ParticleSystemComponent Explosion;

/**
 * The audio component for the explosion.
 */
var AudioComponent ExplosionAudio;

/**
 * The radius of the explosion.
 */
var float Radius;

/**
 * The base damage of the explosion, as would be received by a target at the epicenter.
 */
var float BaseDamage;

/**
 * The base momentum of the explosion, as would be received by a target at the epicenter.
 */
var float BaseMomentum;

/**
 * The display name of the explosion.
 */
var string DisplayName;

/**
 * Indicates that the explosion should happen immediately when this actor is spawned.
 */
var bool AutoExplode;

/**
 * Indicates that the actor will be destroyed once the explosion is complete (based on the particle system).
 */
var bool AutoDestroy;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (AutoExplode)
		Explode();
}

/**
 * Generates the explosion particles and deals damage to every actor within range of the explosion.
 */
simulated function Explode()
{
	local Actor iter;
	local vector hitLoc, hitNorm;
	local TraceHitInfo hitInfo;
	local ImpactInfo impact;
	
	EmitExplosionParticles();
	EmitExplosionLight();
	ExplosionAudio.Play();
	
	if (EntityEffect(Owner) != None)
		EntityEffect(Owner).Affectee.SetHidden(true);
		
	foreach VisibleCollidingActors(class'Actor', iter, Radius, Location)
	{
		impact.HitActor = Trace(hitLoc, hitNorm, iter.Location, Location, True, , hitInfo);
		impact.HitLocation = hitLoc;
		impact.HitNormal = hitNorm;
		impact.RayDir = Normal(iter.Location - Location);
		impact.StartTrace = Location;
		impact.HitInfo = hitInfo;
		
		DamageTarget(impact);
	}
	
	if (EntityEffect(Owner) != None)
		EntityEffect(Owner).Affectee.SetHidden(false);
}

/**
 * Gets the numerical damage for the explosion.  The default implementation scales the damage linearly to the distance from the epicenter.
 */
simulated function float GetDamage(ImpactInfo hitInfo)
{
	return FClamp(BaseDamage * (1 - VSize(hitInfo.HitLocation - Location) / Radius), 0, BaseDamage);
}

/**
 * Gets the numerical momentum for the explosion.  The default implementation scales the damage linearly to the distance from the epicenter.
 */
simulated function float GetMomentum(ImpactInfo hitInfo)
{
	return FClamp(BaseMomentum * (1 - VSize(hitInfo.HitLocation - Location) / Radius), 0, BaseMomentum);
}

simulated function DamageTarget(ImpactInfo hitInfo)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if (hitInfo.HitActor != None)
	{
		if (hitInfo.HitActor.bWorldGeometry)
		{
			HitStaticMesh = StaticMeshComponent(hitInfo.HitInfo.HitComponent);
			
			if ((HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic())
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				
				if (NewKActor != None)
					hitInfo.HitActor = NewKActor;
			}
		}
		
		hitInfo.HitActor.TakeDamage(int(GetDamage(hitInfo)), Instigator.Controller, hitInfo.HitLocation, GetMomentum(hitInfo) * hitInfo.RayDir, DamageType, hitInfo.HitInfo, self);
	}
}

simulated function EmitExplosionParticles()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ExplosionTemplate != None)
	{		
		Explosion = new class'ParticleSystemComponent';
		Explosion.bAutoActivate = false;
		
		AttachComponent(Explosion);
		
		Explosion.SetTemplate(ExplosionTemplate);
		Explosion.OnSystemFinished = ExplosionParticlesComplete;
		Explosion.ActivateSystem();
	}
}

simulated function EmitExplosionLight()
{
	local UDKExplosionLight lightComponent;
	
	if (Light != None)
	{
		lightComponent = new(Outer) Light;
		
		AttachComponent(lightComponent);
	}
}

simulated function ExplosionParticlesComplete(ParticleSystemComponent sender)
{
	if (AutoDestroy)
		Destroy();
}

defaultproperties
{
	AutoDestroy=true
	AutoExplode=true
	
	Begin Object Class=AudioComponent Name=Audio
		bAutoPlay=false
		bStopWhenOwnerDestroyed=false
		bShouldRemainActiveIfDropped=true
	End Object
	ExplosionAudio=Audio
	Components.Add(Audio)
}