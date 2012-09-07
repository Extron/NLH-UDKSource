/*******************************************************************************
	EnvironmentEffect

	Creation date: 08/07/2012 19:37
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* 
 * This is the environment version of a status effect, and keeps track of elemental effects to environment objects. 
 */
class EnvironmentEffect extends Actor;


/* The environment object that is being affected by the effect. */
var Actor Affectee;

/* The player that gave the effect. */
var ArenaPlayerController Affector;

/* The type of damage that this effect causes to players that come in contact with the environment object. */
var Array<class<StatusEffect> > StatusEffects;

/* The properties that the environment object must have to have the effect. */
var Array<string> Properties;

/* The duration of the environment effect. */
var float Duration;

/* The damage the effect deals to pawns that are affected by it. */
var float Damage;

/* The amount to scale the effect's damage by. */
var float DamageFactor;


simulated function UpdateEffect(float delta)
{
}

simulated function ActivateEffect(Actor envobj, ArenaPlayerController player)
{
	Affectee = envobj;
	Affector = player;
	SetTimer(Duration, false, 'DeactivateEffect');
}

simulated function DeactivateEffect()
{
	if (EnvironmentObject(Affectee) != None) 
	{
		EnvironmentObject(Affectee).ActiveEffects.RemoveItem(Self);
	}
	else if (DynamicEnvironmentObject(Affectee) != None) 
	{
		DynamicEnvironmentObject(Affectee).ActiveEffects.RemoveItem(Self);
	}
}

/* 
 * Causes the effect to target a pawn.
 *
 * pawn - The pawn to target
 */
simulated function AffectPawn(ArenaPawn pawn)
{
}