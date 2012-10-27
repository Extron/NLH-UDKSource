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
	abstract;


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

/** The total health damage over time. */
var float HealthDamage;

/** The total energy damage over time. */
var float EnergyDamage;

/** The total stamina damage over time. */
var float StaminaDamage;

/** The total health damage over time. */
var float InitialHealthDamage;

/** The total energy damage over time. */
var float InitialEnergyDamage;

/** The total stamina damage over time. */
var float InitialStaminaDamage;


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

/**
 * Allows the effect to be modified or modifiy other effects that have already been applied to the player.
 */
simulated function CheckState(array<StatusEffect> effects)
{
}

simulated function Tick(float dt)
{
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
	
	CheckState(pawn.ActiveEffects);
	pawn.Stats.AddModifier(StatsModifier);
	
	Affectee.Pawn.TakeDamage(GetInitialHealthDamage(), Affector, pawn.Location, vect(0, 0, 0), DamageType);
	ArenaPawn(Affectee.Pawn).SpendEnergy(GetInitialEnergyDamage());
	ArenaPawn(Affectee.Pawn).SpendStamina(GetInitialStaminaDamage());
	
	if (LocalPlayer(Affectee.Player) != None && LocalPlayer(Affectee.Player).PlayerPostProcess != None && ScreenEffect != None)
	{
		LocalPlayer(Affectee.Player).InsertPostProcessingChain(ScreenEffect, -1, false);
	}
	
	SetTimer(Duration, false, 'DeactivateEffect');
}

function DeactivateEffect()
{
	ArenaPawn(Affectee.Pawn).Stats.RemoveModifier(StatsModifier);
	ArenaPawn(Affectee.Pawn).RemoveEffect(Self);
	
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
}