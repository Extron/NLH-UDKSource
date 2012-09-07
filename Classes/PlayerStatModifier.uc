/*******************************************************************************
	PlayerStatModifier

	Creation date: 09/08/2012 20:12
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* Manages player stat modification, and can be attached to any object to allow that object to affect players' stats. */
class PlayerStatModifier extends Object;


/* Any immunities that the player may have. */
var Array<class<DamageType> > Immunities;

/* A damage map that associates an index with a damage type. */
var Array<class<DamageType> > DamageTypeMap;

/* A list of factors that amplify the player's damage output per damage type. */
var Array<float> TypeDamageOutputMods;

/* A list of factors that modify the damage taken by the player per damage type. */
var Array<float> TypeDamageResistanceMods;

/* A list of factors that modify the damage taken by the player per body part (0 = head, 1 = torso, 2 = abdomen, 3 = arms, 4 = legs). */
var float DamageReductionMods[5];

/* A factor that modifies the player's accuracy. */
var float AccuracyMod;

/* A factor that modifies the player's stability. */
var float StabilityMod;

/* A factor that modifies the player's mobility. */
var float MobilityMod;

/* A factor that modifies the player's weight. */
var float WeightMod;
 
 /* A factor that modifies the player's movement speed. */
var float MovementMod;

/* A factor that modifies the player's jump height. */
var float JumpMod;

/* A factor that modifies the player's health regeneration rate. */
var float HealthRegenMod;

/* A factor that modifies the player's energy regeneration rate. */
var float EnergyRegenMod;

/* A factor that modifies the player's stamina regen rate. */
var float StaminaRegenMod;

/* A factor that modifies all damage taken by the player. */
var float GlobalDamageReductionMod;

/* A factor that changes how long the player must wait before health begins to regenerate. */
var float HealthRegenDelayMod;

/* A factor that modifies how long the player must wait before energy begins to regenerate. */
var float EnergyRegenDelayMod;

/* The multiplicitive factor that modifies ability enegry costs. */
var float EnergyCostFactorMod;

/* Modifies how much energy damage the player takes. */
var float EnergyDamageFactorMod;

/* A factor that modifies the player's melee damage. */
var float MeleeDamageMod;

/* A factor that modifies all damage the player deals to enemies. */
var float GlobalDamageOutputMod;

/* A factor that modifies how obstructed the player's vision is. */
var float ObstructionMod;


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
		TypeDamageResistanceMods.AddItem(1);
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

simulated function SetTypeDamageResistanceMod(class<DamageType> damageType, float factor)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i == -1)
	{
		AddDamageType(damageType);
		i = DamageTypeMap.Length - 1;
	}
	
	TypeDamageResistanceMods[i] = factor;
}

simulated function RemoveDamageType(class<DamageType> damageType)
{
	local int i;
	
	i = DamageTypeMap.Find(damageType);
	
	if (i != -1)
	{
		DamageTypeMap.Remove(i, 1);
		TypeDamageOutputMods.Remove(i, 1);
		TypeDamageResistanceMods.Remove(i, 1);
	}
}

simulated function SetHeadDamageReductionMod(float factor)
{
	DamageReductionMods[0] = factor;
}

simulated function SetTorsoDamageReductionMod(float factor)
{
	DamageReductionMods[1] = factor;
}

simulated function SetAbdominDamageReductionMod(float factor)
{
	DamageReductionMods[2] = factor;
}

simulated function SetLegsDamageReductionMod(float factor)
{
	DamageReductionMods[3] = factor;
}

simulated function SetArmsDamageReductionMod(float factor)
{
	DamageReductionMods[4] = factor;
}