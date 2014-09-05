/*******************************************************************************
	ElectricExplosion

	Creation date: 11/08/2014 23:26
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class ElectricExplosion extends AbilityExplosion;

/**
 * The particle system for a bolt of electricity.
 */
var ParticleSystem LightningBoltTemplate;

/**
 * The delay from the initial explosion to the discharge.
 */
var float DischargeDelay;

/**
 * The number of lightning bolt discharges the explosion should generate.
 */
var int DischargeCount;


simulated function Explode()
{
	EmitExplosionParticles();
	
	SetTimer(DischargeDelay, false, 'Discharge');
}

simulated function float GetDamage(ImpactInfo hitInfo)
{
	return BaseDamage;
}

simulated function Discharge()
{
	local Actor iter;
	local vector hitLoc, hitNorm;
	local TraceHitInfo hitInfo;
	local ImpactInfo impact;
	local int counter;
	local bool prevCA, prevBA;
	
	if (EntityEffect(Owner) != None)
	{
		EntityEffect(Owner).Affectee.bProjTarget = false;
		prevCA = EntityEffect(Owner).Affectee.bCollideActors;
		prevBA = EntityEffect(Owner).Affectee.bBlockActors;
		EntityEffect(Owner).Affectee.SetCollision(false, false);
	}
		
	foreach VisibleCollidingActors(class'Actor', iter, Radius, Location)
	{
		if (counter > DischargeCount)
			break;
			
		if ((IEnvObj(iter) != None && IEnvObj(iter).HasProperty("Conductive")) || (ArenaPawn(iter) != None && ArenaPawn(iter).IsConductive()))
		{
			impact.HitActor = Trace(hitLoc, hitNorm, iter.Location, Location, True, , hitInfo);
			impact.HitLocation = hitLoc;
			impact.HitNormal = hitNorm;
			impact.RayDir = Normal(iter.Location - Location);
			impact.StartTrace = Location;
			impact.HitInfo = hitInfo;
			
			EmitLightningBolt(Location, hitLoc);
			DamageTarget(impact);
		
			counter++;
		}
	}
	
	if (EntityEffect(Owner) != None)
	{
		EntityEffect(Owner).Affectee.bProjTarget = true;
		EntityEffect(Owner).Affectee.SetCollision(prevCA, prevBA);
	}
		
	SetTimer(0.1, false, 'Destroy');
}

simulated function EmitLightningBolt(vector start, vector end)
{
	local ParticleSystemComponent lightningBolt;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && LightningBoltTemplate != None)
	{
		lightningBolt = new class'ParticleSystemComponent';
		
		AttachComponent(lightningBolt);
		
		lightningBolt.SetTemplate(LightningBoltTemplate);
		lightningBolt.bAutoActivate = false;
		lightningBolt.SetAbsolute(false, false, false);
		lightningBolt.SetVectorParameter('HitLocation', end);
		lightningBolt.SetVectorParameter('SourceLocation', start);
		lightningBolt.SetFloatParameter('Distance', VSize(end - start));
		lightningBolt.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		lightningBolt.bUpdateComponentInTick = true;
				
		lightningBolt.ActivateSystem();
	}
}

defaultproperties
{
	AutoDestroy=false
	
	DamageType=class'Arena.Dmg_Shock'
	Radius=1024
	BaseDamage=100
	BaseMomentum=0
	DischargeDelay=0.1
	DischargeCount=10
	
	ExplosionTemplate=ParticleSystem'ArenaAbilities.Particles.ElectricExplosion'
	LightningBoltTemplate=ParticleSystem'ArenaAbilities.Particles.LightningBoltPS'
	
	Begin Object Name=Audio
		SoundCue=SoundCue'ArenaAbilities.Audio.ElectricExplosionSC'
	End Object
	
	DisplayName="Electric Discharge"
}