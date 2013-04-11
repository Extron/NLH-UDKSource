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
var IEnvObj Affectee;

/* The player that gave the effect. */
var ArenaPlayerController Affector;

/* The type of damage that this effect causes to players that come in contact with the environment object. */
var Array<class<StatusEffect> > StatusEffects;

/* The properties that the environment object must have to have the effect. */
var Array<string> Properties;

/* The duration of the environment effect. */
var float Duration;

var float Counter;

/** The name of the effect. */
var string EffectName;


static function EnvironmentEffect AddEffects(EnvironmentEffect A, EnvironmentEffect B)
{
	local EnvironmentEffect sum;
	local int i;
	
	sum = A.Spawn(class'Arena.EnvironmentEffect', None);
	
	sum.Duration = FMax(A.Duration - A.Counter, B.Duration - B.Counter);
	
	for (i = 0; i < A.StatusEffects.Length; i++)
		sum.StatusEffects.AddItem(A.StatusEffects[i]);
	
	for (i = 0; i < A.Properties.Length; i++)
		sum.Properties.AddItem(A.Properties[i]);
		
	for (i = 0; i < B.StatusEffects.Length; i++)
		sum.StatusEffects.AddItem(B.StatusEffects[i]);
		
	for (i = 0; i < B.Properties.Length; i++)
		sum.Properties.AddItem(B.Properties[i]);
		
	sum.Affectee = A.Affectee;
	sum.Affector = A.Affector;
	sum.EffectName = A.EffectName @ "+" @ B.EffectName;
	
	return sum;
}

simulated function UpdateEffect(float dt)
{
	Counter += dt;
}

simulated function ActivateEffect(IEnvObj envobj, ArenaPlayerController player)
{
	Affectee = envobj;
	Affector = player;
		
	SetTimer(Duration, false, 'DeactivateEffect');
}

simulated function DeactivateEffect()
{
	ClearTimer('DeactivateEffect');
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