/*******************************************************************************
	EnvironmentEffect

	Creation date: 08/07/2012 19:37
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* 
 * This is the environment version of a status effect, and keeps track of elemental effects to environment objects. 
 */
class EnvironmentEffect extends Actor
	abstract;


/* The environment object that is being affected by the effect. */
var IEnvObj Affectee;

/* The player that gave the effect. */
var ArenaPlayerController Affector;

/* The type of damage that this effect causes to players that come in contact with the environment object. */
var Array<class<StatusEffect> > StatusEffects;

/* The properties that the environment object must have to have the effect. */
var Array<string> Properties;

/* The duration of the environment effect. */
var float Duration;

/** The name of the effect. */
var string EffectName;


simulated function UpdateEffect(float delta)
{
}

simulated function ActivateEffect(IEnvObj envobj, ArenaPlayerController player)
{
	Affectee = envobj;
	Affector = player;
		
	SetTimer(Duration, false, 'DeactivateEffect');
}

simulated function DeactivateEffect()
{
	Affectee.RemoveEffect(Self);
}

simulated function ChangeState(array<EnvironmentEffect> effects)
{
}

/* 
 * Causes the effect to target a pawn.
 *
 * @param pawn The pawn to target
 */
simulated function AffectPawn(ArenaPawn pawn)
{
	local int i;
	local class<StatusEffect> sClass;
	local StatusEffect status;
	
	for (i = 0; i < StatusEffects.Length; i++)
	{
		sClass = StatusEffects[i];
		
		if (!pawn.HasStatus(Affector, sClass.Default.EffectName, status))
		{
			status = spawn(sClass, Self);
			status.Affector = Affector;
			pawn.AddEffect(status);
		}
	}
}