/*******************************************************************************
	ArenaProjectile

	Creation date: 14/08/2012 21:50
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaProjectile extends UDKProjectile;

/**
 * The weapon that fired the projectile.
 */
var ArenaWeapon Weapon;

/* The tamplate to use for the particles of the projectile. */
var ParticleSystem ProjTemplate;

/* The template to use for the particles for the projectile hitting a wall. */
var ParticleSystem SparksTemplate;

/* The particle system component used to render the projectile. */
var ParticleSystemComponent Projectile;

/* The particle system component used to render the sparks when the projectile hits a wall. */
var ParticleSystemComponent Sparks;

/**
 * The width and height of the projectile's decal.
 */
var float DecalWidth, DecalHeight;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (Instigator != None)
		Weapon = ArenaWeapon(Instigator.Weapon);
		
	//Since this is a projectile, the moment it comes into being, we create the particle effect for it.
	Emit();
}

simulated function HitWall(vector norm, Actor wall, PrimitiveComponent component)
{
	local vector l, n;
	local TraceHitInfo hitInfo;
	local Actor traceActor;
	
	super.HitWall(norm, wall, component);
	
	traceActor = Trace(l, n, Location + Normal(Velocity) * 2, Location - Normal(Velocity) * 2 , , , hitInfo);

	if (traceActor == wall && hitInfo.PhysMaterial != None)
	{
		if (!(ArenaPMP(hitInfo.PhysMaterial.PhysicalMaterialProperty) != None && !ArenaPMP(hitInfo.PhysMaterial.PhysicalMaterialProperty).AllowOtherParticleSystem))
			Spark(norm, hitInfo.PhysMaterial);
			
		SpawnPhysMatEffects(hitInfo.PhysMaterial);
		SpawnDecal(Location, norm, hitInfo.PhysMaterial);
	}
	else
	{
		`log("Trace" @ traceActor @ "Wall" @ wall);
		
		Spark(norm, None);
	}
}
 
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local float dmg;
	
	if (Other != Instigator)
	{
		if (!Other.bStatic && DamageRadius == 0.0)
		{
			if (ArenaPawn(Instigator) != None && Weapon != None)
				dmg = ArenaPawn(Instigator).Stats.GetDamageGiven(Damage * Weapon.Stats.GetDamageModifier(), MyDamageType);
			else
				dmg = Damage;
				
			Other.TakeDamage(dmg, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		}
		Explode(HitLocation, HitNormal);
	}
}

simulated function Emit()
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjTemplate != None && ArenaWeaponBase(Weapon) != None)
	{
		if (SkeletalMeshComponent(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel].Mesh).GetSocketByName(ArenaWeaponBase(Weapon).Sockets[WCBarrel]) != None)
		{
			SkeletalMeshComponent(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel].Mesh).GetSocketWorldLocationAndRotation(ArenaWeaponBase(Weapon).Sockets[WCBarrel], l, r, 0);
			SetLocation(l);
		}
		
		Projectile = WorldInfo.MyEmitterPool.SpawnEmitter(ProjTemplate, vect(0, 0, 0));
		Projectile.SetAbsolute(false, false, false);
		Projectile.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Projectile.bUpdateComponentInTick = true;
		AttachComponent(Projectile);
	}
}

simulated function SpawnDecal(vector loc, vector norm, PhysicalMaterial mat)
{
	local MaterialInterface decalMat;
	local PhysicalMaterial parentMat;
	
	parentMat = mat.Parent;

	if (ArenaPMP(mat.PhysicalMaterialProperty) != None)
		decalMat = ArenaPMP(mat.PhysicalMaterialProperty).GetHitDecal(Weapon);
		
	while (decalMat == None && parentMat != None)
	{
		if (ArenaPMP(parentMat.PhysicalMaterialProperty) != None)
			decalMat = ArenaPMP(parentMat.PhysicalMaterialProperty).GetHitDecal(Weapon);
			
		parentMat = parentMat.Parent;
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && decalMat != None)
		WorldInfo.MyDecalManager.SpawnDecal(decalMat, loc, rotator(-norm), DecalWidth, DecalHeight, 10.0, true);
}

simulated function Spark(vector norm, PhysicalMaterial physMat)
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
		Sparks.SetVectorParameter('SparkVelocity', v + n * 0.25);
		Sparks.SetVectorParameter('DustVelocity', a);
		Sparks.bUpdateComponentInTick = true;
	}
}

simulated function SpawnPhysMatEffects(PhysicalMaterial mat)
{
	local ParticleSystem ps;
	local PhysicalMaterial parentMat;
	local ParticleSystemComponent psc;
	
	parentMat = mat.Parent;

	if (ArenaPMP(mat.PhysicalMaterialProperty) != None)
		ps = ArenaPMP(mat.PhysicalMaterialProperty).GetHitParticleSystem(Weapon);
		
	while (ps == None && parentMat != None)
	{
		if (ArenaPMP(parentMat.PhysicalMaterialProperty) != None)
			ps = ArenaPMP(parentMat.PhysicalMaterialProperty).GetHitParticleSystem(Weapon);
			
		parentMat = parentMat.Parent;
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && ps != None)
	{
		psc = WorldInfo.MyEmitterPool.SpawnEmitter(ps, Location);
		psc.SetAbsolute(false, false, false);
		psc.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		psc.bUpdateComponentInTick = true;
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		ps = None;
		parentMat = mat.Parent;

		if (ArenaPMP(mat.PhysicalMaterialProperty) != None)
		{
			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
				ps = ArenaPMP(mat.PhysicalMaterialProperty).RainHitPS;
			else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
				ps = ArenaPMP(mat.PhysicalMaterialProperty).SnowHitPS;
		}
			
		while (ps == None && parentMat != None)
		{
			if (ArenaPMP(parentMat.PhysicalMaterialProperty) != None)
			{
				if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
					ps = ArenaPMP(mat.PhysicalMaterialProperty).RainHitPS;
				else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
					ps = ArenaPMP(mat.PhysicalMaterialProperty).SnowHitPS;
			}
				
			parentMat = parentMat.Parent;
		}

		if (WorldInfo.NetMode != NM_DedicatedServer && ps != None)
		{
			psc = WorldInfo.MyEmitterPool.SpawnEmitter(ps, Location);
			psc.SetAbsolute(false, false, false);
			psc.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
			psc.bUpdateComponentInTick = true;
		}
	}
}
