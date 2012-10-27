/*******************************************************************************
	EE_Charged

	Creation date: 13/09/2012 18:59
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class EE_Charged extends EnvironmentEffect;

/** The particle template to use when this effect is active. */
var ParticleSystem ActiveTemplate;

/** The particle system of the activated effect. */
var ParticleSystemComponent ActiveEffects;

var float SpreadTime;

var float Counter;

var bool CanSpread;

simulated function UpdateEffect(float dt)
{
	local Actor obj;
	local EnvironmentEffect newEffect;
	
	if (CanSpread)
	{
		if (Counter >= SpreadTime)
		{
			foreach Actor(Affectee).TouchingActors(class'Actor', obj)
			{
				if (IEnvObj(obj) != None)
				{
					if (IEnvObj(obj).HasProperties(Properties) && !IEnvObj(obj).HasEffect(EffectName))
					{
						newEffect = Spawn(class'EE_Charged', obj);
						newEffect.ActivateEffect(obj, Affector);
						
						IEnvObj(obj).AddEffect(newEffect);
					}
				}
			}
		}
		else
		{
			Counter += dt;
		}
	}
}

simulated function ActivateEffect(IEnvObj envobj, ArenaPlayerController player)
{
	super.ActivateEffect(envobj, player);
	
	`log("Activating Charged");
	
	EmitEffect(envobj);
}

simulated function DeactivateEffect()
{
	super.DeactivateEffect();
	
	ActiveEffects.DeactivateSystem();
}

simulated function EmitEffect(IEnvObj envobj)
{	
	if (WorldInfo.NetMode != NM_DedicatedServer && ActiveTemplate != None)
	{
		`log("Emitting particles");
		
		ActiveEffects = WorldInfo.MyEmitterPool.SpawnEmitter(ActiveTemplate, vect(0, 0, 0));
		ActiveEffects.SetAbsolute(false, false, false);
		ActiveEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ActiveEffects.bUpdateComponentInTick = true;
		ActiveEffects.SetActorParameter('EnvObjMesh', Actor(envobj));
	}
}

defaultproperties
{
	StatusEffects[0]=class'SE_Electrocuted'
	
	Properties[0]="Conductive"
	
	ActiveTemplate=ParticleSystem'ArenaParticles.Particles.ChargedParticles'
	EffectName="Charged"
	Duration=15
	CanSpread=false
	SpreadTime=7.5
}