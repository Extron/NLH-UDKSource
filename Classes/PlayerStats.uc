/*******************************************************************************
	PlayerStats

	Creation date: 07/08/2012 21:47
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PlayerStats extends Object;

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
var Array<float> TypeDamageResistance;

/* A reference to the game's constants. */
var GlobalGameConstants Constants;

/* A list of damage reductions for a player's body parts. */
var float DamageReduction[5];

/* The amount of time a player has to avoid damage for before his health starts regenerating. */
var float RegenHealthDelay;

/* The amount of time a player has to wait for energy to start regenerating. */
var float RegenEnergyDelay;

/* The amount of time a player has to wait for energy to start regenerating. */
var float RegenStaminaDelay;

/* The player's health regeneration rate. */
var float HealthRegenRate;

/* The player's energy regeneration rate. */
var float EnergyRegenRate;

/* The player's stamina regeneration rate. */
var float StaminaRegenRate;

/* The total weight that the player is carrying. */
var float Weight;

/* The total amount of mobility that the player has. */
var float Mobility;

/* The total amount of accuracy that the player has. */
var float Accuracy;

/* The total amount of stability that the player has. */
var float Stability;

/* The player's movement speed factor. */
var float Movement;

/* The player's jump height factor. */
var float Jump;

/* The global damage reduction. */
var float GlobalDamageReduction;

/* The level of a player's visual obstruction. */
var float Obstruction;

/* Modifies how much energy the player spends. */
var float EnergyCostFactor;

/* Modifies how much stamina the player spends. */
var float StaminaCostFactor;

/* Modifies how much energy damage the player takes. */
var float EnergyDamageFactor;

/* A factor that modifies the player's melee damage. */
var float MeleeDamage;

/* A factor that modifies all damage the player deals to enemies. */
var float GlobalDamageOutput;

/*
 * Sets the player's initial stats. 
 * 
 * pawn - The pawn to set the stats for.
 */
function SetInitialStats(ArenaPawn pawn, GlobalGameConstants gameConstants)
{
	Owner = pawn;
	Constants = gameConstants;
	ComputeStats();
}

/*
 * Computes the player's weight. 
 * 
 * pawn - The pawn to compute the weight for.
 */
function float GetMovementSpeed()
{
	local float x;
	
	if (Constants != None)
	{
		x = Constants.NormalizedStat("Movement", Movement) * Constants.NormalizedStat("Mobility", Mobility) / (Constants.NormalizedStat("Weight", Weight));
	
		return Constants.GetFactorMin("Movement Speed") * (1 - Constants.GetFactorConstant("Movement Speed") * x) + Constants.GetFactorMax("Movement Speed") * Constants.GetFactorConstant("Movement Speed") * x;
	}
	else
	{
		return 1;
	}
}

function float GetSprintSpeed()
{
	local float x;
	
	if (Constants != None)
	{
		x = Constants.NormalizedStat("Movement", Movement) * Constants.NormalizedStat("Mobility", Mobility) * Constants.NormalizedStat("Health", Owner.FHealth) / (Constants.NormalizedStat("Weight", Weight));
	
		return Constants.GetFactorMin("Sprint Speed") * (1 - Constants.GetFactorConstant("Sprint Speed") * x) + Constants.GetFactorMax("Sprint Speed") * Constants.GetFactorConstant("Sprint Speed") * x;
	}
	else
	{
		return 1;
	}
}

/*
 * Gets the player's health regen rate. 
 * 
 * returns - Returns the healing rate.
 */
function float GetHealingRate()
{
	return ((2 ** (float(Owner.Health) / float(Owner.HealthMax))) - 1) * HealthRegenRate;
}

/*
 * Gets the player's energy regen rate. 
 * 
 * returns - Returns the energy regen rate.
 */
function float GetEnergyRate()
{
	return Owner.EnergyMax * EnergyRegenRate / 10000;
}

function float GetStaminaRate()
{
	return 0;
}

function float GetEnergyCost(float energy)
{
	if (Owner.Energy >= energy * EnergyCostFactor)
	{
		return energy * EnergyCostFactor;
	}
	else
	{
		return 0;
	}
}

function float GetStaminaCost(float stamina)
{
	if (Owner.Stamina >= stamina * StaminaCostFactor)
	{
		return stamina * StaminaCostFactor;
	}
	else
	{
		return 0;
	}
}

/*
 * Gets the player's ADS speed.
 */
function float GetADSSpeed()
{
	local float x;
	
	if (Constants != None)
	{
		x = Constants.NormalizedStat("WeaponWeight", WeaponBase(Owner.Weapon).GetWeight()) / (fmax(Constants.NormalizedStat("Mobility", Mobility), 0.2));

		if (Owner != None && WeaponBase(Owner.Weapon) != None)
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
	
	x = Constants.GetFactorConstant("Accuracy Factor") * (1 / fmax(Accuracy, 0.01));
	
	return Constants.GetFactorMin("Accuracy Factor") * x + Constants.GetFactorMax("Accuracy Factor") * x;
}

function float GetBloomFactor()
{
	local float x;
	
	x = Constants.NormalizedStat("Stability", Stability);
	
	return Constants.GetFactorMin("Bloom Factor") * x + Constants.GetFactorMax("Bloom Factor") * (1 - x);
}

function float GetLookFactor()
{
	if (Constants != None)
	{
		return Constants.GetFactorMin("Look Factor") * (1 - Constants.GetFactorConstant("Look Factor") * Mobility) + Constants.GetFactorMax("Look Factor") * Constants.GetFactorConstant("Look Factor") * Mobility;
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
		x = Constants.NormalizedStat("Mobility", Mobility) * Constants.NormalizedStat("Jump", Jump) * Constants.NormalizedStat("Health", Owner.FHealth) *
			Constants.NormalizedStat("Stamina", Owner.Stamina) / Constants.NormalizedStat("Weight", Weight);
		
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
		return 0;
	
	return initialDamage * GlobalDamageReduction * GetTypeDamageResistance(damageType);
}

function float GetRegenHealthDelay()
{
	return RegenHealthDelay;
}

function float GetRegenEnergyDelay()
{
	return RegenEnergyDelay;
}

function float GetRegenStaminaDelay()
{
	return RegenStaminaDelay;
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
		TypeDamageResistance.AddItem(1);
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

function SetTypeDamageResistance(class<DamageType> damageType, float factor)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		AddDamageType(damageType);
		i = DamageTypeMap.Length - 1;
	}
	
	TypeDamageResistance[i] = factor;
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

function float GetTypeDamageResistance(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		return 1;
	}
	
	return TypeDamageResistance[i];
}

function RemoveDamageType(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i != -1)
	{
		DamageTypeMap.Remove(i, 1);
		TypeDamageOutput.Remove(i, 1);
		TypeDamageResistance.Remove(i, 1);
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
	return Immunities.Find(damageType) == -1;
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

function ResetStats()
{
	if (Constants != None)
	{
		Immunities.Length = 0;
		DamageTypeMap.Length = 0;
		TypeDamageoutput.Length = 0;
		TypeDamageResistance.Length = 0;
		
		DamageReduction[0] *= default.DamageReduction[0];
		DamageReduction[1] *= default.DamageReduction[1];
		DamageReduction[2] *= default.DamageReduction[2];
		DamageReduction[3] *= default.DamageReduction[3];
		DamageReduction[4] *= default.DamageReduction[4];
		
		Accuracy = Constants.GetStatDefault("Accuracy");
		Stability = Constants.GetStatDefault("Stability");
		Mobility = Constants.GetStatDefault("Mobility");
		Weight = Constants.GetStatDefault("Weight");
		Movement = Constants.GetStatDefault("Movement");
		Jump = Constants.GetStatDefault("Jump");
		HealthRegenRate = default.HealthRegenRate;
		EnergyRegenRate = default.EnergyRegenRate;
		StaminaRegenRate = default.StaminaRegenRate;
		GlobalDamageReduction = default.GlobalDamageReduction;
		RegenHealthDelay = default.RegenHealthDelay;
		RegenEnergyDelay = default.RegenEnergyDelay;
		EnergyCostFactor = default.EnergyCostFactor;
		EnergyDamageFactor = default.EnergyDamageFactor;
		MeleeDamage = default.MeleeDamage;
		GlobalDamageOutput = default.GlobalDamageOutput;
	}
}

private function ComputeStats()
{
	local PlayerStatModifier statMod;
	local int i;
	local int j;
	
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
			SetTypeDamageResistance(statMod.DamageTypeMap[j], statMod.TypeDamageResistanceMods[j]);
		}
		
		DamageReduction[0] *= statMod.DamageReductionMods[0];
		DamageReduction[1] *= statMod.DamageReductionMods[1];
		DamageReduction[2] *= statMod.DamageReductionMods[2];
		DamageReduction[3] *= statMod.DamageReductionMods[3];
		DamageReduction[4] *= statMod.DamageReductionMods[4];
		
		Accuracy *= statMod.AccuracyMod;
		Stability *= statMod.StabilityMod;
		Mobility *= statMod.MobilityMod;
		Weight *= statMod.WeightMod;
		Movement *= statMod.MovementMod;
		Jump *= statMod.JumpMod;
		HealthRegenRate *= statMod.HealthRegenMod;
		EnergyRegenRate *= statMod.EnergyRegenMod;
		StaminaRegenRate *= statMod.StaminaRegenMod;
		GlobalDamageReduction *= statMod.GlobalDamageReductionMod;
		RegenHealthDelay *= statMod.HealthRegenDelayMod;
		RegenEnergyDelay *= statMod.EnergyRegenDelayMod;
		EnergyCostFactor *= statMod.energyCostFactorMod;
		EnergyDamageFactor *= statMod.EnergyDamageFactorMod;
		MeleeDamage *= statMod.MeleeDamageMod;
		GlobalDamageOutput *= statMod.GlobalDamageOutputMod;
	}
}

defaultproperties
{
	DamageReduction[0]=1
    DamageReduction[1]=1
    DamageReduction[2]=1
    DamageReduction[3]=1
    DamageReduction[4]=1
    
    Accuracy=50
    Stability=50
    Mobility=50
    Weight=75
    Movement=50
    Jump=50
    HealthRegenRate=1
    EnergyRegenRate=1
    StaminaRegenRate=1
    GlobalDamageReduction=1
    RegenHealthDelay=10
    RegenEnergyDelay=10
    EnergyCostFactor=1
    EnergyDamageFactor=1
    MeleeDamage=1
    GlobalDamageOutput=1
}