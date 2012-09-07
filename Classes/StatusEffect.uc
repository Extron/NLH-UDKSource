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
class StatusEffect extends Actor;


/* The player that is being affected by the status effect. */
var ArenaPlayerController Affectee;

/* The player that spawned the status effect. */
var ArenaPlayerController Affector;

/* The stat modifier for the status effect. */
var PlayerStatModifier StatsModifier;

/* The damage type class that this status carries. */
var class<StatusDamageType> DamageType;

/* The name of the effect. */
var string EffectName;

var float HealthDamage;

var float EnergyDamage;

/* The duration that the status lasts. */
var float Duration;


simulated function ActivateEffect(ArenaPawn pawn)
{
	Affectee = ArenaPlayerController(pawn.Owner);
	
	pawn.TakeDamage(HealthDamage, Affector, pawn.Location, vect(0, 0, 0), DamageType);
	pawn.SpendEnergy(EnergyDamage);
	
	pawn.Stats.AddModifier(StatsModifier);
	
	SetTimer(Duration, false, 'DeactivateEffect');
}

function DeactivateEffect()
{
	ArenaPawn(Affectee.Pawn).Stats.RemoveModifier(StatsModifier);

	ArenaPawn(Affectee.Pawn).RemoveEffect(Self);
}

/*
 * Resets the effect's timer.
 */
function ExtendEffect()
{
	`log("Effect extended");
	ClearTimer('DeactivateEffect');
	SetTimer(Duration, false, 'DeactivateEffect');
}

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=NewStatMod
	End Object
	StatsModifier=NewStatMod
}