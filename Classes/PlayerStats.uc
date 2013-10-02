/*******************************************************************************
	PlayerStats

	Creation date: 07/08/2012 21:47
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PlayerStats extends Component;

/**
 * Helps maintain a list of stat values for a player.
 */
enum PStatValues
{
	PSVWeight,
	PSVMobility,
	PSVAccuracy,
	PSVStability,
	PSVMovement,
	PSVJump,
	PSVMaxHealth,
	PSVMaxEnergy,
	PSVMaxStamina,
	PSVObstruction,
	PSVGlobalDamageInput,
	PSVHealthRegenDelay,
	PSVEnergyRegenDelay,
	PSVStaminaRegenDelay,
	PSVHealthRegenRate,
	PSVEnergyRegenRate,
	PSVStaminaRegenRate,
	PSVEnergyCostFactor,
	PSVStaminaCostFactor,
	PSVEnergyDamageFactor,
	PSVMeleeDamage,
	PSVMeleeRange,
	PSVGlobalDamageOutput,
	PSVAbilityCooldownFactor
};


/* The pawn that owns the stats. */
var ArenaPawn Owner;

/* A list of miscellaneous stat modifiers affecting the player. */
var Array<PlayerStatModifier> StatModifiers;

/* A list of player immunities per data type. */
var Array<class<DamageType> > Immunities;

/* A damage map that associates an index with a damage type. */
var Array<class<DamageType> > DamageTypeMap;

/* A list of factors that amplify the player's damage output per damage type. */
var Array<float> TypeDamageOutput;

/* A list of factors that modify the damage taken by the player per damage type. */
var Array<float> TypeDamageInput;

/* A list of damage reductions for a player's body parts. */
var float DamageInput[5];

/** A list of values, indexed by enum, for the stats. */
var array<float> Values;

/** Stores the starting values of the stats. */
var array<float> DefaultValues;

static function PStatValues GetStatEnum(string statName)
{
	switch (statName)
	{
		case "Weight": return PSVWeight;
		case "Mobility": return PSVMobility;
		case "Accuracy": return PSVAccuracy;
		case "Stability": return PSVStability;
		case "Movement": return PSVMovement;
		case "Jump": return PSVJump;
		case "MaxHealth": case "Health": return PSVMaxHealth;
		case "MaxEnergy": case "Energy": return PSVMaxEnergy;
		case "MaxStamina": return PSVMaxStamina;
		case "Obstruction": return PSVObstruction;
		case "GlobalDamageInput": return PSVGlobalDamageInput;
		case "HealthRegenDelay": return PSVHealthRegenDelay;
		case "EnergyRegenDelay": return PSVEnergyRegenDelay;
		case "StaminaRegenDelay": return PSVStaminaRegenDelay;
		case "HealthRegenRate": return PSVHealthRegenRate;
		case "EnergyRegenRate": return PSVEnergyRegenRate;
		case "StaminaRegenRate": return PSVStaminaRegenRate;
		case "EnergyCostFactor": return PSVEnergyCostFactor;
		case "StaminaCostFactor": return PSVStaminaCostFactor;
		case "EnergyDamageFactor": return PSVEnergyDamageFactor;
		case "MeleeDamage": return PSVMeleeDamage;
		case "MeleeRange": return PSVMeleeRange;
		case "GlobalDamageOutput": return PSVGlobalDamageOutput;
		case "AbilityCooldownFactor": return PSVAbilityCooldownFactor;
	}
	
	return -1;
}

/**
 * Sets the player's initial stats. 
 * 
 * @param pawn - The pawn to set the stats for.
 */
simulated function SetInitialStats(ArenaPawn pawn)
{
	Owner = pawn;
	
	InitValues();
	ComputeStats();
	
	pawn.HealthMax = Values[PSVMaxHealth];
	pawn.Health = int(Values[PSVMaxHealth]);
	pawn.FHealth = Values[PSVMaxHealth];
	
	pawn.EnergyMax = Values[PSVMaxEnergy];
	pawn.Energy = Values[PSVMaxEnergy];
	
	pawn.StaminaMax = Values[PSVMaxStamina];
	pawn.Stamina = Values[PSVMaxStamina];
}

/**
 * Computes the movement speed factor to use.
 * 
 * @returns Returns the movement speed factor.
 */
function float GetMovementSpeed()
{
	local float x;

	x = class'GlobalGameConstants'.static.NormalizedStat("Movement", Values[PSVMovement]) * class'GlobalGameConstants'.static.NormalizedStat("Mobility", Values[PSVMobility]) / 
		(class'GlobalGameConstants'.static.NormalizedStat("Weight", Values[PSVWeight]));

	return class'GlobalGameConstants'.static.GetFactorMin("Movement Speed") * (1 - class'GlobalGameConstants'.static.GetFactorConstant("Movement Speed") * x) + 
		   class'GlobalGameConstants'.static.GetFactorMax("Movement Speed") * class'GlobalGameConstants'.static.GetFactorConstant("Movement Speed") * x;
}

/**
 * Computes the sprint speed factor to use during sprinting.
 *
 * @returns Returns the sprint factor to increase the movement speed with.
 */
function float GetSprintSpeed()
{
	local float x;

	x = class'GlobalGameConstants'.static.NormalizedStat("Movement", Values[PSVMovement]) * class'GlobalGameConstants'.static.NormalizedStat("Mobility", Values[PSVMobility]) * 
		class'GlobalGameConstants'.static.NormalizedStat("Health", Owner.FHealth) / (class'GlobalGameConstants'.static.NormalizedStat("Weight", Values[PSVWeight]));

	return class'GlobalGameConstants'.static.GetFactorMin("Sprint Speed") * (1 - class'GlobalGameConstants'.static.GetFactorConstant("Sprint Speed") * x) + 
		   class'GlobalGameConstants'.static.GetFactorMax("Sprint Speed") * class'GlobalGameConstants'.static.GetFactorConstant("Sprint Speed") * x;
}

/**
 * Gets the player's health regen rate. 
 * 
 * @returns Returns the healing rate.
 */
function float GetHealingRate()
{
	if (Owner != None)
	{
		if (Owner.HealthMax == 0)
			return 0;
		else
			return ((2 ** (float(Owner.Health) / float(Owner.HealthMax))) - 1) * Values[PSVHealthRegenRate];
	}
	
	return 0;
}

/**
 * Gets the player's energy regen rate. 
 * 
 * @returns - Returns the energy regen rate.
 */
function float GetEnergyRate()
{
	//TODO: This is not the final version of the energy rate algorithm.
	return Owner.EnergyMax * Values[PSVEnergyRegenRate] / 10000;
}

/**
 * Gets the player's stamina regen rate. 
 * 
 * @returns - Returns the stamina regen rate.
 */
function float GetStaminaRate()
{
	//TODO: This is not the final version of the stamina rate algorithm.
	return Owner.StaminaMax * Values[PSVStaminaRegenRate] / 10000;
}

/**
 * Gets the player's maximum health. 
 * 
 * @returns - Returns the maximum health.
 */
function float GetMaxHealth()
{
	return Values[PSVMaxHealth];
}

/**
 * Gets the player's maximum energy. 
 * 
 * @returns - Returns the maximum energy.
 */
function float GetMaxEnergy()
{
	return Values[PSVMaxEnergy];
}

/**
 * Gets the player's maximum stamina. 
 * 
 * @returns - Returns the maximum stamina.
 */
function float GetMaxStamina()
{
	return Values[PSVMaxStamina];
}

/**
 * Changes a specified amount of energy to change based on the energy cost factor.
 * 
 * @param energy - The energy cost to change.
 * @returns - Returns the changed energy cost.
 */
function float GetEnergyCost(float energy)
{
	if (Owner.Energy >= energy * Values[PSVEnergyCostFactor])
	{
		return energy * Values[PSVEnergyCostFactor];
	}
	else
	{
		return 0;
	}
}

/*
 * Changes a specified amount of stamina to change based on the stamina cost factor.
 * 
 * @param stamina - The stamina cost to change.
 * @returns - Returns the changed stamina cost.
 */
function float GetStaminaCost(float stamina)
{
	if (Owner.Stamina >= stamina * Values[PSVStaminaCostFactor])
	{
		return stamina * Values[PSVStaminaCostFactor];
	}
	else
	{
		return 0;
	}
}

/**
 * Gets the player's ADS speed.
 *
 * @returns Returns the amount of time in seconds that the user should spend aiming down the sights.
 */
function float GetADSSpeed()
{
	local float x;
	
	x = class'GlobalGameConstants'.static.NormalizedStat("Weapon Weight", ArenaWeaponBase(Owner.Weapon).GetWeight()) / 
		(2.0 * fmax(class'GlobalGameConstants'.static.NormalizedStat("Mobility", Values[PSVMobility]), 0.2));

	if (Owner != None && ArenaWeaponBase(Owner.Weapon) != None)
	{		
		return class'GlobalGameConstants'.static.GetFactorMax("ADS Speed") * class'GlobalGameConstants'.static.GetFactorConstant("ADS Speed") * x + 
			   class'GlobalGameConstants'.static.GetFactorMin("ADS Speed") * (1 - class'GlobalGameConstants'.static.GetFactorConstant("ADS Speed") * x);
	}
	else
	{
		return 0.25;
	}
}

/**
 * Gets the multiplicitave factor to change the reload speed by.
 *
 * @returns Returns the factor to change the reload speed by.
 */
function float GetReloadSpeed()
{
	//TODO: Add in the equation to compute this.
	return 1;
}

/**
 * Gets the multiplicitave factor to change the cycle speed by.
 *
 * @returns Returns the factor to change the cycle speed by.
 */
function float GetCycleSpeed()
{
	//TODO: Add in the equation to compute this.
	return 1;
}

/**
 * Gets the multiplicitave factor to change the equip speed by.
 */
function float GetEquipSpeed()
{
	//TODO: Add in the equation to compute this.
	return 1;
}

function float GetInaccuracyFactor()
{
	local float x;
	
	x = class'GlobalGameConstants'.static.GetFactorConstant("Accuracy Factor") * (1 / fmax(Values[PSVAccuracy], 0.01));
	
	return class'GlobalGameConstants'.static.GetFactorMin("Accuracy Factor") * x + class'GlobalGameConstants'.static.GetFactorMax("Accuracy Factor") * x;
}

function float GetBloomFactor()
{
	local float x;
	
	x = class'GlobalGameConstants'.static.NormalizedStat("Stability", Values[PSVStability]);
	
	return class'GlobalGameConstants'.static.GetFactorMin("Bloom Factor") * x + class'GlobalGameConstants'.static.GetFactorMax("Bloom Factor") * (1 - x);
}

function float GetLookFactor()
{
	return class'GlobalGameConstants'.static.GetFactorMin("Look Factor") * (1 - class'GlobalGameConstants'.static.GetFactorConstant("Look Factor") * Values[PSVMobility]) + 
		   class'GlobalGameConstants'.static.GetFactorMax("Look Factor") * class'GlobalGameConstants'.static.GetFactorConstant("Look Factor") * Values[PSVMobility];
}

function float GetJumpZ()
{
	local float x;

	x = class'GlobalGameConstants'.static.NormalizedStat("Mobility", Values[PSVMobility]) * class'GlobalGameConstants'.static.NormalizedStat("Jump", Values[PSVJump]) * 
		class'GlobalGameConstants'.static.NormalizedStat("Health", Owner.FHealth) * class'GlobalGameConstants'.static.NormalizedStat("Stamina", Owner.Stamina) / 
		class'GlobalGameConstants'.static.NormalizedStat("Weight", Values[PSVWeight]);
	
	if (Owner != None)
	{
		return class'GlobalGameConstants'.static.GetFactorMax("Jump Z") * class'GlobalGameConstants'.static.GetFactorConstant("Jump Z") * x + 
			   class'GlobalGameConstants'.static.GetFactorMin("Jump Z") * (1 - class'GlobalGameConstants'.static.GetFactorConstant("Jump Z") * x);
	}
	else
	{
		return 1;
	}
}

function float GetDamageTaken(float initialDamage, class<DamageType> damageType)
{
	if (IsImmune(damageType))
	{
		`log("Is immune.");
		return 0;
	}
	
	`log("Damages" @ initialDamage @ Values[PSVGlobalDamageInput] @ GetTypeDamageInput(damageType));
	return initialDamage * Values[PSVGlobalDamageInput] * GetTypeDamageInput(damageType);
}

function float GetDamageGiven(float initialDamage, class<DamageType> damageType)
{
	return initialDamage * Values[PSVGlobalDamageOutput] * GetTypeDamageOutput(damageType);
}

function float GetRegenHealthDelay()
{
	return Values[PSVHealthRegenDelay];
}

function float GetRegenEnergyDelay()
{
	return Values[PSVEnergyRegenDelay];
}

function float GetRegenStaminaDelay()
{
	return Values[PSVStaminaRegenDelay];
}

function float GetMeleeDamage()
{
	return Values[PSVMeleeDamage] * Values[PSVGlobalDamageOutput];
}

simulated function SetMeleeDamage(float mod)
{
	Values[PSVMeleeDamage] *= mod;
}

function float GetMeleeRange()
{
	return Values[PSVMeleeRange];
}

/**
 * Computes the real cooldown time for an ability once the cooldown factor is applied.
 *
 * @param time - The original cooldown time.
 * @returns Returns the resulting cooldown time after a factor has been applied.
 */
function float GetCooldownTime(float time)
{
	return time * Values[PSVAbilityCooldownFactor];
}

function AddImmunity(class<DamageType> damageType)
{
	if (Immunities.Find(damageType) == -1)
	{
		Immunities.AddItem(damageType);
	}
}

function RemoveImmunity(class<DamageType> damageType)
{
	Immunities.RemoveItem(damageType);
}

function AddDamageType(class<DamageType> damageType)
{
	if (DamageTypeMap.Find(damageType) == -1)
	{
		DamageTypeMap.AddItem(damageType);
		TypeDamageOutput.AddItem(1);
		TypeDamageInput.AddItem(1);
	}
}

function SetTypeDamageOutput(class<DamageType> damageType, float factor)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		AddDamageType(damageType);
		i = DamageTypeMap.Length - 1;
	}
	
	TypeDamageOutput[i] = factor;
}

function SetTypeDamageInput(class<DamageType> damageType, float factor)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		AddDamageType(damageType);
		i = DamageTypeMap.Length - 1;
	}
	
	TypeDamageInput[i] = factor;
}

function float GetTypeDamageOutput(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		return 1;
	}
	
	return TypeDamageOutput[i];
}

function float GetTypeDamageInput(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		return 1;
	}
	
	return TypeDamageInput[i];
}

function RemoveDamageType(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i != -1)
	{
		DamageTypeMap.Remove(i, 1);
		TypeDamageOutput.Remove(i, 1);
		TypeDamageInput.Remove(i, 1);
	}
}

/*
 * Determines if the player is immune to a specific type of damage.
 *
 * damageType - The type of damage to test.
 * returns - Returns whether or not the pawn is immune.
 */
function bool IsImmune(class<DamageType> damageType)
{
	return Immunities.Find(damageType) != -1;
}

function AddModifier(PlayerStatModifier mod)
{
	StatModifiers.AddItem(mod);
	ComputeStats();
}

function RemoveModifier(PlayerStatModifier mod)
{
	StatModifiers.RemoveItem(mod);
	ComputeStats();
}

function ClearModifiers()
{
	StatModifiers.Length = 0;
}

function InitValues()
{
	local int i;
	
	for (i = 0; i < Values.Length; i++)
	{
		if (Values[i] == -1 && GetGGC(i) != -1)
			DefaultValues[i] = GetGGC(i);
		else
			DefaultValues[i] = Values[i];
	}
}

function ResetStats()
{
	local int i;
	
	Immunities.Length = 0;
	DamageTypeMap.Length = 0;
	TypeDamageoutput.Length = 0;
	TypeDamageInput.Length = 0;
	
	DamageInput[0] *= default.DamageInput[0];
	DamageInput[1] *= default.DamageInput[1];
	DamageInput[2] *= default.DamageInput[2];
	DamageInput[3] *= default.DamageInput[3];
	DamageInput[4] *= default.DamageInput[4];
		
	for (i = 0; i < Values.Length; i++)
	{
		Values[i] = DefaultValues[i];
	}
}

function ComputeStats()
{
	local PlayerStatModifier statMod;
	local int i, j;

	ResetStats();

	for (i = 0; i < StatModifiers.Length; i++)
	{
		statMod = StatModifiers[i];
			
		for (j = 0; j < statMod.Immunities.Length; j++)
		{
			AddImmunity(statMod.Immunities[j]);
		}
		
		for (j = 0; j < statMod.DamageTypeMap.Length; j++)
		{
			if (DamageTypeMap.Find(statMod.DamageTypeMap[j]) == -1)
			{
				AddDamageType(statMod.DamageTypeMap[j]);
			}
			
			SetTypeDamageOutput(statMod.DamageTypeMap[j], statMod.TypeDamageOutputMods[j]);
			SetTypeDamageInput(statMod.DamageTypeMap[j], statMod.TypeDamageInputMods[j]);
		}
		
		DamageInput[0] *= statMod.DamageInputMods[0];
		DamageInput[1] *= statMod.DamageInputMods[1];
		DamageInput[2] *= statMod.DamageInputMods[2];
		DamageInput[3] *= statMod.DamageInputMods[3];
		DamageInput[4] *= statMod.DamageInputMods[4];
		
		for (j = 0; j < Values.Length; j++)
			Values[j] *= statMod.ValueMods[j];
	}
}

simulated function float GetGGC(int i)
{
	switch (i)
	{
	case 0:
		return class'GlobalGameConstants'.static.GetStatDefault("Weight");
		
	case 1:
		return class'GlobalGameConstants'.static.GetStatDefault("Mobility");
		
	case 2:
		return class'GlobalGameConstants'.static.GetStatDefault("Accuracy");
		
	case 3:
		return class'GlobalGameConstants'.static.GetStatDefault("Stability");
		
	case 4:
		return class'GlobalGameConstants'.static.GetStatDefault("Movement");
		
	case 5:
		return class'GlobalGameConstants'.static.GetStatDefault("Jump");
		
	case 6:
		return class'GlobalGameConstants'.static.GetStatDefault("Health");
		
	case 7:
		return class'GlobalGameConstants'.static.GetStatDefault("Energy");
		
	case 8:
		return class'GlobalGameConstants'.static.GetStatDefault("Stamina");
		
	default:
		return -1;
	}
}

defaultproperties
{
	DamageInput[0]=1
    DamageInput[1]=1
    DamageInput[2]=1
    DamageInput[3]=1
    DamageInput[4]=1
    
	Values[PSVWeight]=-1
	Values[PSVMaxHealth]=1000
	Values[PSVMaxEnergy]=1000
	Values[PSVMaxStamina]=1000
	Values[PSVMobility]=-1
	Values[PSVAccuracy]=-1
	Values[PSVStability]=-1
	Values[PSVMovement]=-1
	Values[PSVJump]=-1
	Values[PSVObstruction]=0
	Values[PSVGlobalDamageInput]=1
	Values[PSVHealthRegenDelay]=1
	Values[PSVEnergyRegenDelay]=5
	Values[PSVStaminaRegenDelay]=1
	Values[PSVHealthRegenRate]=10
	Values[PSVEnergyRegenRate]=10
	Values[PSVStaminaRegenRate]=10
	Values[PSVEnergyCostFactor]=1
	Values[PSVStaminaCostFactor]=1
	Values[PSVEnergyDamageFactor]=1
	Values[PSVMeleeDamage]=1
	Values[PSVMeleeRange]=5
	Values[PSVGlobalDamageOutput]=1
	Values[PSVAbilityCooldownFactor]=1
}