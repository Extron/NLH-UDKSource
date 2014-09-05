/*******************************************************************************
	EE_Charged

	Creation date: 13/09/2012 18:59
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class EE_Charged extends EnvironmentEffect;

/**
 * The particle template to use when this effect is active. 
 */
var ParticleSystem ActiveTemplate_Static;

/**
 * The particle system for dynamic environment objects.
 */
var ParticleSystem ActiveTemplate_Dynamic;

/** 
 * The particle system of the activated effect.
 */
var ParticleSystemComponent ActiveEffects;

/**
 * The light to illuminate the object with when charged.
 */
var class<LightComponent> LightClass;

/**
 * Add a light component to whatever was hit.
 */
var LightComponent Light;

/**
 * The time it takes for the charge to spread to nearby objects.
 */
var float SpreadTime;

/**
 * Indicates that the charge can spread to other objects.
 */
var bool CanSpread;


simulated function Tick(float dt)
{
	local Actor obj;
	
	super.Tick(dt);
	
	if (CanSpread)
	{
		if (Counter >= SpreadTime)
		{
			foreach Affectee.TouchingActors(class'Actor', obj)
			{
				if (IEnvObj(obj) != None)
				{
					if (IEnvObj(obj).HasProperties(Properties) && !IEnvObj(obj).HasEffect(EffectName))
						IEnvObj(obj).AddEffect(Spawn(class'EE_Charged', obj));
				}
			}
		}
	}
	
	if (Light != None)
	{
		if (FRand() > 0.5)
		{
			Light.SetLightProperties(Lerp(15, 64, FRand()));
			
			Light.UpdateColorAndBrightness();
		}		
	}
}

simulated function ActivateEffect(Actor target)
{
	super.ActivateEffect(target);
	
	if (IEnvObj(target) != None)
		EmitEffect(IEnvObj(target));
}

simulated function DeactivateEffect()
{	
	Affectee.DetachComponent(Light);
	ActiveEffects.DeactivateSystem();
	
	super.DeactivateEffect();
}

simulated function EmitEffect(IEnvObj envobj)
{	
	local vector scale;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ActiveTemplate_Static != None && ActiveTemplate_Dynamic != None)
	{
		if (DynamicEnvironmentObject(envobj) != None)
			ActiveEffects = WorldInfo.MyEmitterPool.SpawnEmitter(ActiveTemplate_Dynamic, vect(0, 0, 0));
		else
			ActiveEffects = WorldInfo.MyEmitterPool.SpawnEmitter(ActiveTemplate_Static, vect(0, 0, 0));
			
		ActiveEffects.SetAbsolute(false, false, false);
		ActiveEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ActiveEffects.bUpdateComponentInTick = true;
		
		if (DynamicEnvironmentObject(envobj) != None)
		{
			ActiveEffects.SetFloatParameter('Radius', DynamicEnvironmentObject(envobj).StaticMeshComponent.Bounds.SphereRadius / DynamicEnvironmentObject(envobj).DrawScale);
			
			scale.x = DynamicEnvironmentObject(envobj).StaticMeshComponent.Bounds.SphereRadius / 2.0;
			scale.y = DynamicEnvironmentObject(envobj).StaticMeshComponent.Bounds.SphereRadius / 2.0;
			scale.z = DynamicEnvironmentObject(envobj).StaticMeshComponent.Bounds.SphereRadius / 2.0;
		
			ActiveEffects.SetVectorParameter('Scale', scale);
			DynamicEnvironmentObject(envobj).AttachComponent(ActiveEffects);
		}
		else
		{
			ActiveEffects.SetActorParameter('EnvObjMesh', Actor(envobj));
		}
	}
	
	if (WorldInfo.NetMode != NM_DedicatedServer && (DynamicEnvironmentObject(envobj) != None || EnvironmentObject(envobj) != None))
	{
		if (Light != None)
		{
			Actor(envobj).AttachComponent(Light);	
		}
		else if (LightClass != None)
		{
			Light = new(Outer) LightClass;
			Actor(envobj).AttachComponent(Light);			
		}
	}
}

defaultproperties
{
	DamageTypes[0]=class'Arena.Dmg_Shock'
	
	Properties[0]="Conductive"
	
	ActiveTemplate_Static=ParticleSystem'ArenaParticles.Particles.ChargedParticles'
	ActiveTemplate_Dynamic=ParticleSystem'ArenaParticles.Particles.ChargedDEOParticles'
	LightClass=class'Arena.L_ChargedLight'
	
	EffectName="Charged"
	Duration=15
	CanSpread=false
	SpreadTime=7.5
	
	Explosions[0]=(Trigger=class'Arena.Dmg_Water',ExplosionType=class'Arena.ElectricExplosion')
}