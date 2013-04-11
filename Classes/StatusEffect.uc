/*******************************************************************************
	StatusEffect

	Creation date: 08/07/2012 18:43
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/*
 * A status effect is attached to a player to modify certain properties of the player.  
 * For example, players with the electrocuted status effect will suffer some damage, 
 * have slower movement speed, and experience HUD and mod malfunctions.
 */
class StatusEffect extends Actor
	dependson(PlayerStats);

/**
 * These bit flags are used to specify what class group a status effect belongs to.
 * Many status effects will have a pure group, but the bit flag nature of these constants
 * allow hybrid class groups to be created.
 */
const SEG_None = 0;
const SEG_Electromagnetism = 1;
const SEG_Water = 2;
const SEG_Earth = 4;


/**
 * The weights for the player stat modifiers.
 */
var array<float> PSMWeights;

/**
 * Indicates which direction the weights are applied.  A positive number indicates that 
 * the values are only modified when the added effect trumps the initial effect, and 
 * a negative number works vice versa.
 */
var array<int> PSMDirections;

/* The player that is being affected by the status effect. */
var ArenaPlayerController Affectee;

/* The player that spawned the status effect. */
var ArenaPlayerController Affector;

/* The stat modifier for the status effect. */
var PlayerStatModifier StatsModifier;

/* The damage type class that this status carries. */
var class<StatusDamageType> DamageType;

/** A reference to the screen effect to use while this effect is active. */
var PostProcessChain ScreenEffect;

/* The name of the effect. */
var string EffectName;

/* The duration that the status lasts. */
var float Duration;

/**
 * A counter representing how long this effect has been active.
 */
var float Counter;

/**
 * This weight controls how strongly the duration of this effect is applied to any effects created from this and
 * another effect.
 */
var float DurationWeight;

/** 
 * The total health damage over time. 
 */
var float HealthDamage;

/**
 * The weight of the health damage over time.
 */
var float HealthDamageWeight;

/** 
 * The total energy damage over time. 
 */
var float EnergyDamage;

/**
 * The weight of energy damage over time.
 */
var float EnergyDamageWeight;

/**
 * The total stamina damage over time. 
 */
var float StaminaDamage;

/**
 * The weight of stamina damage over time.
 */
var float StaminaDamageWeight;

/**
 * The total health damage over time. 
 */
var float InitialHealthDamage;

/**
 * The weight of the initial health damage.
 */
var float IHDWeight;

/**
 * The total energy damage over time. 
 */
var float InitialEnergyDamage;

/**
 * The weight of the initial energy damage.
 */
var float IEDWeight;

/**
 * The total stamina damage over time. 
 */
var float InitialStaminaDamage;

/**
 * The weight of the initial stamina damage.
 */
var float ISDWeight;

/**
 * The SE Group of the status effect.
 */
var int SEGroup;



static function StatusEffect AddEffects(StatusEffect A, StatusEffect B)
{
	local StatusEffect se;
	local int advantage;
	local int i;
	
	se = A.Spawn(class'Arena.StatusEffect', None);
	advantage = GetAdvantageValue(A.SEGroup, B.SEGroup);
	
	se.SEGroup = A.SEGroup | B.SEGroup;
	se.EffectName = A.EffectName @ "+" @ B.EffectName;
	
	se.Duration = WeightedAddition(A.Duration - A.Counter, B.Duration - B.Counter, B.DurationWeight, -advantage);
	se.HealthDamage = WeightedAddition(A.HealthDamage, B.HealthDamage, B.HealthDamageWeight, advantage);
	se.EnergyDamage = WeightedAddition(A.EnergyDamage, B.EnergyDamage, B.EnergyDamageWeight, advantage);
	se.StaminaDamage = WeightedAddition(A.StaminaDamage, B.StaminaDamage, B.StaminaDamageWeight, -advantage);
	se.InitialHealthDamage = WeightedAddition(A.InitialHealthDamage, B.InitialHealthDamage, B.IHDWeight, advantage);
	se.InitialEnergyDamage = WeightedAddition(A.InitialEnergyDamage, B.InitialEnergyDamage, B.IEDWeight, advantage);
	se.InitialStaminaDamage = WeightedAddition(A.InitialStaminaDamage, B.InitialStaminaDamage, B.ISDWeight, -advantage);
	
	for (i = 0; i < se.StatsModifier.ValueMods.Length; i++)
		se.StatsModifier.ValueMods[i] = WeightedAddition(A.StatsModifier.ValueMods[i], B.StatsModifier.ValueMods[i], B.PSMWeights[i], advantage * B.PSMDirections[i]);
	
	for (i = 0; i < B.PSMWeights.Length; i++)
		se.PSMWeights[i] = WeightedAddition(A.PSMWeights[i], B.PSMWeights[i], 1.0, advantage);
	
	se.ScreenEffect = A.ScreenEffect;
	se.Affectee = A.Affectee;
	
	return se;
}

static function int GetAdvantageValue(int SEG_A, int SEG_B)
{
	local int value;
	
	value = 0;
	
	if ((SEG_A & SEG_Electromagnetism) == SEG_Electromagnetism)
	{
		if ((SEG_B & SEG_Water) == SEG_Water)
			value += 1;
			
		if ((SEG_B & SEG_Earth) == SEG_Earth)
			value -= 1;
	}
	
	if ((SEG_A & SEG_Water) == SEG_Water)
	{
		if ((SEG_B & SEG_Electromagnetism) == SEG_Electromagnetism)
			value -= 1;
			
		if ((SEG_B & SEG_Earth) == SEG_Earth)
			value += 1;
	}
	
	if ((SEG_A & SEG_Earth) == SEG_Earth)
	{
		if ((SEG_B & SEG_Electromagnetism) == SEG_Electromagnetism)
			value += 1;
			
		if ((SEG_B & SEG_Water) == SEG_Water)
			value -= 1;
	}
	
	return value;
}

static function float WeightedAddition(float a, float b, float weight, int advantage)
{
	return FMax(a, b) + Clamp(advantage, 0, 1) * (2 ** advantage) * b * weight;
}


/**
 * Gets the health damage per tick of the effect.
 */
simulated function float GetHealthDamage(float dt)
{
	return 0;
}

/**
 * Gets the energy damage per tick of the effect.
 */
simulated function float GetEnergyDamage(float dt)
{
	return 0;
}

/**
 * Gets the stamina damage per tick of the effect.
 */
simulated function float GetStaminaDamage(float dt)
{
	return 0;
}

/**
 * Gets the initial health damage of the effect.
 */
simulated function float GetInitialHealthDamage()
{
	return InitialHealthDamage;
}

/**
 * Gets the initial energy damage of the effect.
 */
simulated function float GetInitialEnergyDamage()
{
	return InitialEnergyDamage;
}

/**
 * Gets the initial stamina damage of the effect.
 */
simulated function float GetInitialStaminaDamage()
{
	return InitialStaminaDamage;
}

/**
 * Determines if health damage should be applied this tick. 
 */
simulated function bool ApplyHealthDamage()
{
	return false;
}

/**
 * Determines if energy damage should be applied this tick. 
 */
simulated function bool ApplyEnergyDamage()
{
	return false;
}

/**
 * Determines if stamina damage should be applied this tick. 
 */
simulated function bool ApplyStaminaDamage()
{
	return false;
}


simulated function Tick(float dt)
{
	Counter += dt;
	
	if (Affectee != None && ArenaPawn(Affectee.Pawn) != None)
	{
		if (ApplyHealthDamage())
			Affectee.Pawn.TakeDamage(GetHealthDamage(dt), Affector, Affectee.Pawn.Location, vect(0, 0, 0), DamageType);
		
		if (ApplyEnergyDamage())
			ArenaPawn(Affectee.Pawn).SpendEnergy(GetEnergyDamage(dt));
			
		if (ApplyStaminaDamage())
			ArenaPawn(Affectee.Pawn).SpendStamina(GetStaminaDamage(dt));
	}
}

simulated function ActivateEffect(ArenaPawn pawn)
{
	Affectee = ArenaPlayerController(pawn.Owner);
	
	pawn.Stats.AddModifier(StatsModifier);
	
	Affectee.Pawn.TakeDamage(GetInitialHealthDamage(), Affector, pawn.Location, vect(0, 0, 0), DamageType);
	ArenaPawn(Affectee.Pawn).SpendEnergy(GetInitialEnergyDamage());
	ArenaPawn(Affectee.Pawn).SpendStamina(GetInitialStaminaDamage());
	
	if (LocalPlayer(Affectee.Player) != None && LocalPlayer(Affectee.Player).PlayerPostProcess != None && ScreenEffect != None)
	{
		LocalPlayer(Affectee.Player).InsertPostProcessingChain(ScreenEffect, 0, false);
	}
	
	SetTimer(Duration, false, 'EffectEnded');
}

function EffectEnded()
{
	if (Affectee != None && ArenaPawn(Affectee.Pawn) != None)
		ArenaPawn(Affectee.Pawn).RemoveEffect();
}

function DeactivateEffect()
{
	`log("Deactivating effect.");
	ClearTimer('EffectEnded');
	
	ArenaPawn(Affectee.Pawn).Stats.RemoveModifier(StatsModifier);
	
	if (LocalPlayer(Affectee.Player) != None && LocalPlayer(Affectee.Player).PlayerPostProcess != None && ScreenEffect != None)
	{
		LocalPlayer(Affectee.Player).RemovePostProcessingChain(0);
	}
}

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=NewStatMod
	End Object
	StatsModifier=NewStatMod
	
	PSMWeights[PSVWeight]=0
	PSMWeights[PSVMobility]=0
	PSMWeights[PSVAccuracy]=0
	PSMWeights[PSVStability]=0
	PSMWeights[PSVMovement]=0
	PSMWeights[PSVJump]=0
	PSMWeights[PSVMaxHealth]=0
	PSMWeights[PSVMaxEnergy]=0
	PSMWeights[PSVMaxStamina]=0
	PSMWeights[PSVObstruction]=0
	PSMWeights[PSVGlobalDamageInput]=0
	PSMWeights[PSVHealthRegenDelay]=0
	PSMWeights[PSVEnergyRegenDelay]=0
	PSMWeights[PSVStaminaRegenDelay]=0
	PSMWeights[PSVHealthRegenRate]=0
	PSMWeights[PSVEnergyRegenRate]=0
	PSMWeights[PSVStaminaRegenRate]=0
	PSMWeights[PSVEnergyCostFactor]=0
	PSMWeights[PSVStaminaCostFactor]=0
	PSMWeights[PSVEnergyDamageFactor]=0
	PSMWeights[PSVMeleeDamage]=0
	PSMWeights[PSVMeleeRange]=0
	PSMWeights[PSVGlobalDamageOutput]=0
	PSMWeights[PSVAbilityCooldownFactor]=0
	
	PSMDirections[PSVWeight]=0
	PSMDirections[PSVMobility]=0
	PSMDirections[PSVAccuracy]=0
	PSMDirections[PSVStability]=0
	PSMDirections[PSVMovement]=0
	PSMDirections[PSVJump]=0
	PSMDirections[PSVMaxHealth]=0
	PSMDirections[PSVMaxEnergy]=0
	PSMDirections[PSVMaxStamina]=0
	PSMDirections[PSVObstruction]=0
	PSMDirections[PSVGlobalDamageInput]=0
	PSMDirections[PSVHealthRegenDelay]=0
	PSMDirections[PSVEnergyRegenDelay]=0
	PSMDirections[PSVStaminaRegenDelay]=0
	PSMDirections[PSVHealthRegenRate]=0
	PSMDirections[PSVEnergyRegenRate]=0
	PSMDirections[PSVStaminaRegenRate]=0
	PSMDirections[PSVEnergyCostFactor]=0
	PSMDirections[PSVStaminaCostFactor]=0
	PSMDirections[PSVEnergyDamageFactor]=0
	PSMDirections[PSVMeleeDamage]=0
	PSMDirections[PSVMeleeRange]=0
	PSMDirections[PSVGlobalDamageOutput]=0
	PSMDirections[PSVAbilityCooldownFactor]=0
}