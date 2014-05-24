/*******************************************************************************
	Proj_EMP

	Creation date: 21/04/2013 20:41
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * The projectile for the ranged EMP ability.  Detonates at a specified range or if it hits something.
 */
class Proj_EMP extends ArenaProjectile;


/**
 * The template to use for instant hits for the ability.
 */
var ParticleSystem EMPBurstTemplate;

/**
 * The instance of the IH Beam particle system.
 */
var ParticleSystemComponent EMPBurst;


simulated function Emit()
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjTemplate != None && ArenaAbility(Owner) != None)
	{
		`log("Emitting projectile PS.");
		
		if (ArenaPawn(Owner.Instigator) != None)
		{	
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);
			`log("Got position." @ l);
			SetLocation(l);
		}
		
		Projectile = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjTemplate);
		Projectile.SetAbsolute(false, false, false);
		Projectile.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Projectile.bUpdateComponentInTick = true;
		AttachComponent(Projectile);
		
		SetTimer(LifeSpan - 0.1, false, 'LifeEnded');
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	EMPBlast();
	Destroy();
}

/**
 * Fires an EMP burst, affecting all players in the burst's radius.
 */
simulated function EMPBlast()
{
	local ArenaPawn iter;

	EmitEMPBurst();
	
	if (ArenaPawn(Instigator) != None)
	{
		foreach WorldInfo.AllPawns(class'ArenaPawn', iter, Location, DamageRadius)
		{
			iter.RebootElectronics(ArenaPawn(Instigator));
		}
	}
}

simulated function EmitEMPBurst()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && EMPBurstTemplate != None)
	{		
		EMPBurst = WorldInfo.MyEmitterPool.SpawnEmitter(EMPBurstTemplate, Location);
		EMPBurst.SetAbsolute(false, false, false);
		EMPBurst.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		EMPBurst.bUpdateComponentInTick = true;
	}
}

simulated function LifeEnded()
{
	Explode(vect(0, 0, 0), vect(0, 0, 0));
}

defaultproperties
{
	ProjTemplate=ParticleSystem'ArenaParticles.Particles.EMPBall'
	//SparksTemplate=ParticleSystem'ArenaParticles.Particles.BulletImpactSparks'	
	EMPBurstTemplate=ParticleSystem'ArenaParticles.Particles.EMPBubble'
	
	//MyDamageType=class'Arena.Dmg_RifleBullet'
	
	Speed=1000
	MaxSpeed=1000
	AccelRate=0
	LifeSpan=1.5

	Damage=0
	DamageRadius=1000
	MomentumTransfer=0
	
	ProjectileTag="EMP"
}