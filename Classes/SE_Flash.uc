/*******************************************************************************
	SE_Flash

	Creation date: 16/04/2013 14:25
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SE_Flash extends StatusEffect;

var MaterialInstanceConstant FlashMaterial;


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

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	FlashMaterial.SetScalarParameterValue('FlashAmount', 1 - Counter / Duration);
}

simulated function ActivateEffect(ArenaPawn pawn)
{
	local MaterialEffect effect;
	
	Affectee = ArenaPlayerController(pawn.Owner);
	
	pawn.Stats.AddModifier(StatsModifier);
	
	Affectee.Pawn.TakeDamage(GetInitialHealthDamage(), Affector, pawn.Location, vect(0, 0, 0), DamageType);
	ArenaPawn(Affectee.Pawn).SpendEnergy(GetInitialEnergyDamage());
	ArenaPawn(Affectee.Pawn).SpendStamina(GetInitialStaminaDamage());
	
	if (LocalPlayer(Affectee.Player) != None && LocalPlayer(Affectee.Player).PlayerPostProcess != None && ScreenEffect != None)
	{
		effect = MaterialEffect(ScreenEffect.FindPostProcessEffect('FlashMat'));
		
		if (effect != None)
		{
			FlashMaterial = new class'MaterialInstanceConstant';
			FlashMaterial.SetParent(effect.Material);
			effect.Material = FlashMaterial;
		}
		
		LocalPlayer(Affectee.Player).InsertPostProcessingChain(ScreenEffect, 0, false);
	}
	
	SetTimer(Duration, false, 'EffectEnded');
}

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.5
		ValueMods[PSVStability]=0.15
		ValueMods[PSVAccuracy]=0.15
	End Object
	
	EffectName="Flashed"
	Duration=1
	SEGroup=SEG_Electromagnetism
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.FlashedPPC';
	
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