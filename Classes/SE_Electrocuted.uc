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

/**
 * The total health damage that the effect should do over its duration.
 */
var float HealthDamage;

/**
 * The total energy damage that the effect should do over its duration.
 */
var float EnergyDamage;

/**
 * The total stamina damage that the effect should do over its duration.
 */
var float StaminaDamage;


simulated function Tick(float dt)
{
	super.Tick(dt);
	
	if (ArenaPawn(Affectee) != None)
    {
        ArenaPawn(Affectee).TakeDamage(HealthDamage * dt / Duration, Instigator.Controller, Affectee.Location, vect(0, 0, 0), DamageType);
        ArenaPawn(Affectee).SpendEnergy(EnergyDamage * dt / Duration);
        ArenaPawn(Affectee).SpendStamina(StaminaDamage * dt / Duration);
    }
}

simulated function ActivateEffect(Actor target)
{
	super.ActivateEffect(target);
	
	if (ArenaPawn(target) != None)
		EmitActivePS(ArenaPawn(target));
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

simulated function DeactivateEffect()
{
	if (ActivePS != None)
		ActivePS.DeactivateSystem();
		
	super.DeactivateEffect();
}

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.25
		ValueMods[PSVStability]=0.15
		ValueMods[PSVGlobalDamageInput]=1.5
		
	End Object
	
	DisplayColor=0x0BB5FF
	
	EffectName="Electrocuted"
	Duration=5
	DamageType=class'Arena.SDT_Electrocuted'
	Group=EG_Electromagnetism
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.ElectrocutedPPC'
	ActiveTemplate=ParticleSystem'ArenaParticles.Particles.ChargedDEOParticles'
	
	HealthDamage=50
	EnergyDamage=50
	StaminaDamage=25
	
	Explosions[0]=(Trigger=class'Arena.Dmg_Water',ExplosionType=class'Arena.ElectricExplosion')
}