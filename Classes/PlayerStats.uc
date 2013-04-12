/*******************************************************************************
	PlayerStats

	Creation date: 07/08/2012 21:47
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PlayerStats extends Object;

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

/* A reference to the game's constants. */
var GlobalGameConstants Constants;

/* A list of damage reductions for a player's body parts. */
var float DamageInput[5];

/** A list of values, indexed by enum, for the stats. */
var array<float> Values;

/** Stores the starting values of the stats. */
var array<float> DefaultValues;


/**
 * Sets the player's initial stats. 
 * 
 * @param pawn - The pawn to set the stats for.
 */
simulated function SetInitialStats(ArenaPawn pawn, GlobalGameConstants gameConstants)
{
	Owner = pawn;
	Constants = gameConstants;
	
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

	if (Constants != None)
	{
		x = Constants.NormalizedStat("Movement", Values[PSVMovement]) * Constants.NormalizedStat("Mobility", Values[PSVMobility]) / (Constants.NormalizedStat("Weight", Values[PSVWeight]));
	
		return Constants.GetFactorMin("Movement Speed") * (1 - Constants.GetFactorConstant("Movement Speed") * x) + Constants.GetFactorMax("Movement Speed") * Constants.GetFactorConstant("Movement Speed") * x;
	}
	else
	{
		return 1;
	}
}

/**
 * Computes the sprint speed factor to use during sprinting.
 *
 * @returns Returns the sprint factor to increase the movement speed with.
 */
function float GetSprintSpeed()
{
	local float x;
	
	if (Constants != None)
	{
		x = Constants.NormalizedStat("Movement", Values[PSVMovement]) * Constants.NormalizedStat("Mobility", Values[PSVMobility]) * Constants.NormalizedStat("Health", Owner.FHealth) / (Constants.NormalizedStat("Weight", Values[PSVWeight]));
	
		return Constants.GetFactorMin("Sprint Speed") * (1 - Constants.GetFactorConstant("Sprint Speed") * x) + Constants.GetFactorMax("Sprint Speed") * Constants.GetFactorConstant("Sprint Speed") * x;
	}
	else
	{
		return 1;
	}
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
	
	if (Constants != None)
	{
		x = Constants.NormalizedStat("WeaponWeight", ArenaWeaponBase(Owner.Weapon).GetWeight()) / (fmax(Constants.NormalizedStat("Mobility", Values[PSVMobility]), 0.2));

		if (Owner != None && ArenaWeaponBase(Owner.Weapon) != None)
		{		
			return Constants.GetFactorMax("ADS Speed") * Constants.GetFactorConstant("ADS Speed") * x + Constants.GetFactorMin("ADS Speed") * (1 - Constants.GetFactorConstant("ADS Speed") * x);
		}
		else
		{
			return 0.25;
		}
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
	
	x = Constants.GetFactorConstant("Accuracy Factor") * (1 / fmax(Values[PSVAccuracy], 0.01));
	
	return Constants.GetFactorMin("Accuracy Factor") * x + Constants.GetFactorMax("Accuracy Factor") * x;
}

function float GetBloomFactor()
{
	local float x;
	
	x = Constants.NormalizedStat("Stability", Values[PSVStability]);
	
	return Constants.GetFactorMin("Bloom Factor") * x + Constants.GetFactorMax("Bloom Factor") * (1 - x);
}

function float GetLookFactor()
{
	if (Constants != None)
	{
		return Constants.GetFactorMin("Look Factor") * (1 - Constants.GetFactorConstant("Look Factor") * Values[PSVMobility]) + 
			   Constants.GetFactorMax("Look Factor") * Constants.GetFactorConstant("Look Factor") * Values[PSVMobility];
	}
	else
	{
		return 1;
	}
}

function float GetJumpZ()
{
	local float x;

	if (Constants != None)
	{
		x = Constants.NormalizedStat("Mobility", Values[PSVMobility]) * Constants.NormalizedStat("Jump", Values[PSVJump]) * Constants.NormalizedStat("Health", Owner.FHealth) *
			Constants.NormalizedStat("Stamina", Owner.Stamina) / Constants.NormalizedStat("Weight", Values[PSVWeight]);
		
		if (Owner != None)
		{
			return Constants.GetFactorMax("Jump Z") * Constants.GetFactorConstant("Jump Z") * x + Constants.GetFactorMin("Jump Z") * (1 - Constants.GetFactorConstant("Jump Z") * x);
		}
		else
		{
			return 1;
		}
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

function InitValues()
{
	local int i;
	
	for (i = 0; i < Values.Length; i++)
	{
		if (Values[i] == -1 && Constants != None && GetGGC(i) != -1)
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
		{
			Values[j] *= statMod.ValueMods[j];
		}
	}
}

simulated function float GetGGC(int i)
{
	switch (i)
	{
	case 0:
		return Constants.GetStatDefault("Weight");
		
	case 1:
		return Constants.GetStatDefault("Mobility");
		
	case 2:
		return Constants.GetStatDefault("Accuracy");
		
	case 3:
		return Constants.GetStatDefault("Stability");
		
	case 4:
		return Constants.GetStatDefault("Movement");
		
	case 5:
		return Constants.GetStatDefault("Jump");
		
	case 6:
		return Constants.GetStatDefault("Health");
		
	case 7:
		return Constants.GetStatDefault("Energy");
		
	case 8:
		return Constants.GetStatDefault("Stamina");
		
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