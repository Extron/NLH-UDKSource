/*******************************************************************************
	EE_Charged

	Creation date: 13/09/2012 18:59
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class EE_Charged extends EnvironmentEffect;

/** The particle template to use when this effect is active. */
var ParticleSystem ActiveTemplate_Static;

/**
 * The particle system for dynamic environment objects.
 */
var ParticleSystem ActiveTemplate_Dynamic;

/** The particle system of the activated effect. */
var ParticleSystemComponent ActiveEffects;

var float SpreadTime;

var bool CanSpread;

simulated function UpdateEffect(float dt)
{
	local Actor obj;
	
	super.UpdateEffect(dt);
	
	if (CanSpread)
	{
		if (Counter >= SpreadTime)
		{
			foreach Actor(Affectee).TouchingActors(class'Actor', obj)
			{
				if (IEnvObj(obj) != None)
				{
					if (IEnvObj(obj).HasProperties(Properties) && !IEnvObj(obj).HasEffect(EffectName))
						IEnvObj(obj).AddEffect(Spawn(class'EE_Charged', obj), Affector);
				}
			}
		}
	}
}

simulated function ActivateEffect(IEnvObj envobj, ArenaPlayerController player, bool isBase)
{
	super.ActivateEffect(envobj, player, isBase);
	
	EmitEffect(envobj);
}

simulated function DeactivateEffect()
{
	super.DeactivateEffect();
	
	ActiveEffects.DeactivateSystem();
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
}

defaultproperties
{
	StatusEffects[0]=class'SE_Electrocuted'
	
	Properties[0]="Conductive"
	
	ActiveTemplate_Static=ParticleSystem'ArenaParticles.Particles.ChargedParticles'
	ActiveTemplate_Dynamic=ParticleSystem'ArenaParticles.Particles.ChargedDEOParticles'
	EffectName="Charged"
	Duration=15
	CanSpread=false
	SpreadTime=7.5
}