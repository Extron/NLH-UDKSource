/*******************************************************************************
	SE_Electrocuted

	Creation date: 10/09/2012 15:03
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SE_Electrocuted extends StatusEffect;

/**
 * The particle system template to use when the status effect is active.
 */
var ParticleSystem ActiveTemplate;

/**
 * The particle system to emit when the effect is active.
 */
var ParticleSystemComponent ActivePS;


simulated function float GetHealthDamage(float dt)
{
	return HealthDamage * dt / Duration;
}

simulated function float GetEnergyDamage(float dt)
{
	return EnergyDamage * dt / Duration;
}

simulated function float GetStaminaDamage(float dt)
{
	return StaminaDamage * dt / Duration;
}

simulated function bool ApplyHealthDamage()
{
	return true;
}

simulated function bool ApplyEnergyDamage()
{
	return true;
}

simulated function bool ApplyStaminaDamage()
{
	return true;
}


simulated function ActivateEffect(ArenaPawn pawn)
{
	super.ActivateEffect(pawn);
	
	EmitActivePS(pawn);
}

simulated function EmitActivePS(ArenaPawn pawn)
{	
	local vector scale;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ActiveTemplate != None)
	{
		ActivePS = WorldInfo.MyEmitterPool.SpawnEmitter(ActiveTemplate, vect(0, 0, 0));
			
		ActivePS.SetAbsolute(false, false, false);
		ActivePS.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ActivePS.bUpdateComponentInTick = true;

		ActivePS.SetFloatParameter('Radius', pawn.Mesh.Bounds.SphereRadius / pawn.DrawScale);
		
		scale.x = pawn.Mesh.Bounds.SphereRadius / 2.0;
		scale.y = pawn.Mesh.Bounds.SphereRadius / 2.0;
		scale.z = pawn.Mesh.Bounds.SphereRadius / 2.0;
		
		ActivePS.SetVectorParameter('Scale', scale);
		
		pawn.AttachComponent(ActivePS);
	}
}

function DeactivateEffect()
{
	super.DeactivateEffect();
	
	if (ActivePS != None)
		ActivePS.DeactivateSystem();
}

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.25
		ValueMods[PSVStability]=0.15
		ValueMods[PSVGlobalDamageInput]=1.5
		
	End Object
	
	DisplayColors[0]=0x0BB5FF
	
	EffectName="Electrocuted"
	Duration=5
	DamageType=class'Arena.SDT_Electrocuted'
	SEGroup=SEG_Electromagnetism
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.ElectrocutedPPC'
	ActiveTemplate=ParticleSystem'ArenaParticles.Particles.ChargedDEOParticles'
	
	InitialHealthDamage=100
	InitialEnergyDamage=25
	InitialStaminaDamage=5
	
	HealthDamage=50
	EnergyDamage=50
	StaminaDamage=25
	
	DurationWeight=1
	HealthDamageWeight=1
	EnergyDamageWeight=0.5
	StaminaDamageWeight=0.25
	IHDWeight=1
	IEDWeight=0.5
	ISDWeight=0.25
}