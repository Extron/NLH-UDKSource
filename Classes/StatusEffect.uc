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
 * Contains a list of explosions and their triggers that the status effect can generate.
 */
struct ExplosionData
{
	/**
	 * The damage effect that can trigger the explosion.
	 */
	var class<AbilityDamageType> Trigger;
	
	/**
	 * The explosion that is generated.
	 */
	var class<AbilityExplosion> ExplosionType;
};

/**
 * A list of explosion types that this status effect can generate when struct by a secondary damage type.
 */
var array<ExplosionData> Explosions;

/**
 * The list of display colors to use when showing this status effect.  Length should agree with Combinations variable.
 */
var array<int> DisplayColors;

/* The player that is being affected by the status effect. */
var Controller Affectee;

/* The player that spawned the status effect. */
var Controller Affector;

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
 * The points that this status effect gives if a pawn is killed directly by this effect.
 */
var float KilledByPoints;

/**
 * The points that this status effect gives if a pawn had this status effect when they died.
 */
var float KilledWhilePoints;

/**
 * The SE Group of the status effect.
 */
var int SEGroup;


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
	Affectee = Controller(pawn.Owner);
	
	pawn.Stats.AddModifier(StatsModifier);
	
	Affectee.Pawn.TakeDamage(GetInitialHealthDamage(), Affector, pawn.Location, vect(0, 0, 0), DamageType);
	ArenaPawn(Affectee.Pawn).SpendEnergy(GetInitialEnergyDamage());
	ArenaPawn(Affectee.Pawn).SpendStamina(GetInitialStaminaDamage());
	
	if (PlayerController(Affectee) != None)
	{
		if (LocalPlayer(PlayerController(Affectee).Player) != None && LocalPlayer(PlayerController(Affectee).Player).PlayerPostProcess != None && ScreenEffect != None)
			LocalPlayer(PlayerController(Affectee).Player).InsertPostProcessingChain(ScreenEffect, 0, false);
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
	ClearTimer('EffectEnded');
	
	ArenaPawn(Affectee.Pawn).Stats.RemoveModifier(StatsModifier);
	
	if (PlayerController(Affectee) != None)
	{
		if (LocalPlayer(PlayerController(Affectee).Player) != None && LocalPlayer(PlayerController(Affectee).Player).PlayerPostProcess != None && ScreenEffect != None)
			LocalPlayer(PlayerController(Affectee).Player).RemovePostProcessingChain(0);
	}
}

simulated function bool CanTriggleExplosion(class<AbilityDamageType> triggerDamageType)
{
	local int i;
	
	for (i = 0; i < Explosions.Length; i++)
	{
		if (Explosions[i].Trigger == triggerDamageType)
			return true;
	}
	
	return false;
}

simulated function Explode(class<AbilityDamageType> triggerDamageType)
{
	
	local int i;
	
	for (i = 0; i < Explosions.Length; i++)
	{
		if (Explosions[i].Trigger == triggerDamageType)
		{
			Spawn(Explosions[i].ExplosionType, self, , Affectee.Pawn.Location);
			DeactivateEffect();
			return;
		}
	}
}

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=NewStatMod
	End Object
	StatsModifier=NewStatMod
	
	DisplayColors[0]=0xFFFFFF
}