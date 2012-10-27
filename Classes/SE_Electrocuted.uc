/*******************************************************************************
	SE_Electrocuted

	Creation date: 10/09/2012 15:03
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SE_Electrocuted extends StatusEffect;


simulated function float GetHealthDamage(float dt)
{
	//TOOD Make this more interesting.
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

simulated function ChangeState(array<StatusEffect> effects)
{
	//if (effects[effects.Length - 1]
}

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.25
		ValueMods[PSVStability]=0.15
		ValueMods[PSVGlobalDamageInput]=1.5
		
	End Object
	
	EffectName="Electrocuted"
	Duration=5
}