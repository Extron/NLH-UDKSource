/*******************************************************************************
	PlayerStatModifier

	Creation date: 09/08/2012 20:12
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* Manages player stat modification, and can be attached to any object to allow
	that object to affect players' stats. */
class PlayerStatModifier extends Component
	dependson(PlayerStats);


/* Any immunities that the player may have. */
var Array<class<DamageType> > Immunities;

/* A damage map that associates an index with a damage type. */
var Array<class<DamageType> > DamageTypeMap;

/* A list of factors that amplify the player's damage output per damage type. */
var Array<float> TypeDamageOutputMods;

/* A list of factors that modify the damage taken by the player per damage
	type. */
var Array<float> TypeDamageInputMods;

/* A list of factors that modify the damage taken by the player per body part
	(0 = head, 1 = torso, 2 = abdomen, 3 = arms, 4 = legs). */
var float DamageInputMods[5];

/** A list of all mods, indexed by enum, for the player stats. */
var array<float> ValueMods;


simulated function AddImunity(class<DamageType> damageType)
{
	Immunities.AddItem(damageType);
}

simulated function RemoveImmunity(class<DamageType> damageType)
{
	Immunities.RemoveItem(damageType);
}

simulated function AddDamageType(class<DamageType> damageType)
{
	if (DamageTypeMap.Find(damageType) == -1)
	{
		DamageTypeMap.AddItem(damageType);
		TypeDamageOutputMods.AddItem(1);
		TypeDamageInputMods.AddItem(1);
	}
}

simulated function SetTypeDamageOutputMod(class<DamageType> damageType, float factor)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		AddDamageType(damageType);
		i = DamageTypeMap.Length - 1;
	}
	
	TypeDamageOutputMods[i] = factor;
}

simulated function SetTypeDamageInputMod(class<DamageType> damageType, float factor)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		AddDamageType(damageType);
		i = DamageTypeMap.Length - 1;
	}
	
	TypeDamageInputMods[i] = factor;
}

simulated function RemoveDamageType(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i != -1)
	{
		DamageTypeMap.Remove(i, 1);
		TypeDamageOutputMods.Remove(i, 1);
		TypeDamageInputMods.Remove(i, 1);
	}
}

simulated function SetHeadDamageInputMod(float factor)
{
	DamageInputMods[0] = factor;
}

simulated function SetTorsoDamageInputMod(float factor)
{
	DamageInputMods[1] = factor;
}

simulated function SetAbdominDamageInputMod(float factor)
{
	DamageInputMods[2] = factor;
}

simulated function SetLegsDamageInputMod(float factor)
{
	DamageInputMods[3] = factor;
}

simulated function SetArmsDamageInputMod(float factor)
{
	DamageInputMods[4] = factor;
}

/**
 * Scales all values in the stat mod by the specified scalar.
 */
simulated function ScaleValues(float scale)
{
	local int i;
	
	if (!(scale > 0))
		return;
		
	for (i = 0; i < ValueMods.Length; i++)
		ValueMods[i] = FMax(ValueMods[i] * scale, 0.01);
		
	for (i = 0; i < 5; i++)
		DamageInputMods[i] *= scale;
		
	for (i = 0; i < TypeDamageOutputMods.Length; i++)
		TypeDamageOutputMods[i] *= scale;
		
	for (i = 0; i < TypeDamageInputMods.Length; i++)
		TypeDamageInputMods[i] *= scale;
}

defaultproperties
{
	ValueMods[PSVWeight]=1
	ValueMods[PSVMobility]=1
	ValueMods[PSVAccuracy]=1
	ValueMods[PSVStability]=1
	ValueMods[PSVMovement]=1
	ValueMods[PSVJump]=1
	ValueMods[PSVMaxHealth]=1
	ValueMods[PSVMaxEnergy]=1
	ValueMods[PSVMaxStamina]=1
	ValueMods[PSVObstruction]=1
	ValueMods[PSVGlobalDamageInput]=1
	ValueMods[PSVHealthRegenDelay]=1
	ValueMods[PSVEnergyRegenDelay]=1
	ValueMods[PSVStaminaRegenDelay]=1
	ValueMods[PSVHealthRegenRate]=1
	ValueMods[PSVEnergyRegenRate]=1
	ValueMods[PSVStaminaRegenRate]=1
	ValueMods[PSVEnergyCostFactor]=1
	ValueMods[PSVStaminaCostFactor]=1
	ValueMods[PSVEnergyDamageFactor]=1
	ValueMods[PSVMeleeDamage]=1
	ValueMods[PSVMeleeRange]=1
	ValueMods[PSVGlobalDamageOutput]=1
	ValueMods[PSVAbilityCooldownFactor]=1
	
	DamageInputMods[0]=1
	DamageInputMods[1]=1
	DamageInputMods[2]=1
	DamageInputMods[3]=1
	DamageInputMods[4]=1
}