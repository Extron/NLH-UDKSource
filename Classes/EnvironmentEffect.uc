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

/**
 * The parent effects of the effect.  Used for effect addition.
 */
var Array<EnvironmentEffect> ParentEffects;

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
	
	`log("Adding effect" @ A @ B);
	
	sum = A.Spawn(class'Arena.EnvironmentEffect', None);
	
	sum.Duration = FMax(A.Duration - A.Counter, B.Duration - B.Counter);

	for (i = 0; i < A.Properties.Length; i++)
		sum.Properties.AddItem(A.Properties[i]);

	for (i = 0; i < B.Properties.Length; i++)
		sum.Properties.AddItem(B.Properties[i]);
			
	sum.Affectee = A.Affectee;
	sum.Affector = A.Affector;
	sum.EffectName = A.EffectName @ "+" @ B.EffectName;
	sum.ParentEffects.AddItem(B);
	sum.ParentEffects.AddItem(A);
	
	return sum;
}

simulated function UpdateEffect(float dt)
{
	local int i;
	
	Counter += dt;

	for (i = 0; i < ParentEffects.Length; i++)
	{
		if (ParentEffects[i].Counter < ParentEffects[i].Duration)
			ParentEffects[i].UpdateEffect(dt);
	}
}

simulated function ActivateEffect(IEnvObj envobj, ArenaPlayerController player, bool isBase)
{
	local int i;
	
	Affectee = envobj;
	Affector = player;
	
	`log("Activating effect" @ self @ isBase);
	
	for (i = 0; i < ParentEffects.Length; i++)
	{
		`log("Parent Effect" @ i @ ParentEffects[i]);
		
		ParentEffects[i].ActivateEffect(envobj, player, false);
	}
	
	if (isBase)
		SetTimer(Duration, false, 'EffectEnded');
	else
		SetTimer(Duration, false, 'DeactivateEffect');
}

function EffectEnded()
{
	`log("Effect ended" @ self);
	
	if (IEnvObj(Affectee) != None)
		IEnvObj(Affectee).RemoveEffect();
}

simulated function DeactivateEffect()
{
	local int i;
	
	ClearTimer('EffectEnded');
	
	`log("Deactivating effect" @ self);
	
	for (i = 0; i < ParentEffects.Length; i++)
	{
		ParentEffects[i].DeactivateEffect();
	}
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
	
	for (i = 0; i < ParentEffects.Length; i++)
	{
		if (ParentEffects[i].Counter < ParentEffects[i].Duration)
			ParentEffects[i].AffectPawn(pawn);
	}
	
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

simulated function EnvironmentEffect FindEffect(name className)
{
	local int i;
	local EnvironmentEffect effect;
	
	if (ParentEffects.Length == 0)
	{
		if (IsA(className))
			return self;
		else 
			return None;
	}
	
	for (i = 0; i < ParentEffects.Length; i++)
	{
		if (ParentEffects[i].IsA(className))
			return ParentEffects[i];
		
		effect = ParentEffects[i].FindEffect(className);
		
		if (effect != None)
			return effect;
	}
	
	return None;
}