/*******************************************************************************
	ArenaProjectile

	Creation date: 14/08/2012 21:50
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaProjectile extends UDKProjectile;

/* The tamplate to use for the particles of the projectile. */
var ParticleSystem ProjTemplate;

/* The template to use for the particles for the projectile hitting a wall. */
var ParticleSystem SparksTemplate;

/* The particle system component used to render the projectile. */
var ParticleSystemComponent Projectile;

/* The particle system component used to render the sparks when the projectile hits a wall. */
var ParticleSystemComponent Sparks;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	//Since this is a projectile, the moment it comes into being, we create the particle effect for it.
	Emit();
}

simulated function HitWall(vector normal, Actor wall, PrimitiveComponent component)
{
	super.HitWall(normal, wall, component);
	Spark(normal);
}
 
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function Emit()
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjTemplate != None && ArenaWeaponBase(Owner) != None)
	{
		if (SkeletalMeshComponent(ArenaWeaponBase(Owner).Barrel.Mesh).GetSocketByName('MuzzleSocket') != None)
		{
			SkeletalMeshComponent(ArenaWeaponBase(Owner).Barrel.Mesh).GetSocketWorldLocationAndRotation('MuzzleSocket', l, r, 0);
			SetLocation(l);
		}
		
		Projectile = WorldInfo.MyEmitterPool.SpawnEmitter(ProjTemplate, vect(0, 0, 0));
		Projectile.SetAbsolute(false, false, false);
		Projectile.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Projectile.bUpdateComponentInTick = true;
		AttachComponent(Projectile);
	}
}

simulated function Spark(vector norm)
{
	local vector v;
	local vector a;
	local vector n;
	
	n = Normal(norm);
	a = vect(0, 0, 1);
	
	if (n == a)
		a = vect(1, 0, 0);
		
	v = a + n cross a;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && SparksTemplate != None)
	{
		Sparks = WorldInfo.MyEmitterPool.SpawnEmitter(SparksTemplate, Location);
		Sparks.SetAbsolute(false, false, false);
		Sparks.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		//ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		Sparks.SetVectorParameter('SparkVelocity', v + n * 0.25);
		Sparks.SetVectorParameter('DustVelocity', a);
		Sparks.bUpdateComponentInTick = true;
	}
}