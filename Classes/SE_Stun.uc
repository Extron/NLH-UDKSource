/*******************************************************************************
	SE_Stun

	Creation date: 23/06/2013 02:37
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SE_Stun extends StatusEffect;

var MaterialInstanceTimeVarying StunMaterial;

simulated function float GetHealthDamage(float dt)
{
	return 0;
}

simulated function float GetEnergyDamage(float dt)
{
	return 0;
}

simulated function float GetStaminaDamage(float dt)
{
	return 0;
}

simulated function bool ApplyHealthDamage()
{
	return false;
}

simulated function bool ApplyEnergyDamage()
{
	return false;
}

simulated function bool ApplyStaminaDamage()
{
	return false;
}

simulated function ActivateEffect(ArenaPawn pawn)
{
	local MaterialEffect effect;
	
	Affectee = ArenaPlayerController(pawn.Owner);
	
	pawn.Stats.AddModifier(StatsModifier);
	
	pawn.TakeDamage(GetInitialHealthDamage(), Affector, pawn.Location, vect(0, 0, 0), DamageType);
	pawn.SpendEnergy(GetInitialEnergyDamage());
	pawn.SpendStamina(GetInitialStaminaDamage());
	
	if (LocalPlayer(PlayerController(Affectee).Player) != None && LocalPlayer(PlayerController(Affectee).Player).PlayerPostProcess != None && ScreenEffect != None)
	{
		effect = MaterialEffect(ScreenEffect.FindPostProcessEffect('StunMat'));
		
		if (effect != None)
		{
			StunMaterial = new class'MaterialInstanceTimeVarying';
			StunMaterial.SetParent(effect.Material);
			StunMaterial.SetDuration(Duration);
			effect.Material = StunMaterial;
		}
		
		LocalPlayer(PlayerController(Affectee).Player).InsertPostProcessingChain(ScreenEffect, 0, false);
	}
	
	SetTimer(Duration, false, 'EffectEnded');
}

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.25
		ValueMods[PSVStability]=0.25
		ValueMods[PSVAccuracy]=0.35
	End Object
	
	EffectName="Stunned"
	Duration=0.75
	SEGroup=SEG_Earth
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.StunnedPPC';
	
	InitialHealthDamage=0
	InitialEnergyDamage=0
	InitialStaminaDamage=0
	
	HealthDamage=0
	EnergyDamage=0
	StaminaDamage=0
	
	DurationWeight=0
	HealthDamageWeight=0
	EnergyDamageWeight=0
	StaminaDamageWeight=0
	IHDWeight=0
	IEDWeight=0
	ISDWeight=0
}