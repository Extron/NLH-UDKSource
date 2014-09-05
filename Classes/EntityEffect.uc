/*******************************************************************************
	EntityEffect

	Creation date: 27/08/2014 08:57
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * Encapsulates an effect that can be placed on an entity in game.
 */
class EntityEffect extends Actor;

enum EffectGroup
{
	EG_None,
	EG_Electromagnetism,
	EG_Water,
	EG_Earth
};

/**
 * Contains a list of explosions and their triggers that the status effect can generate.
 */
struct ExplosionData
{
	/**
	 * The damage effect that can trigger the explosion.
	 */
	var class<ElementDamageType> Trigger;
	
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
 * The actor that the effect has been applied to.
 */
var Actor Affectee;

/**
 * The name of the effect.
 */
var string EffectName;

/**
 * The duration of the effect.
 */
var float Duration;

/**
 * Keeps track of how long the effect has been around.
 */
var float Counter;

/**
 * The group that the effect belongs to.
 */
var EffectGroup Group;


simulated function Tick(float dt)
{
	Counter += dt;
	
	if (Counter > Duration)
		DeactivateEffect();
}

simulated function DeactivateEffect()
{
	Destroy();
}

/**
 * Activates the effect on the specified target.
 */
simulated function ActivateEffect(Actor target)
{
	Affectee = target;
	Counter = 0;
}

/**
 * Checks to see if the a specific damage type can cause an explosion from this effect.
 */	
simulated function bool CanTriggleExplosion(class<ElementDamageType> triggerDamageType)
{
	local int i;
	
	for (i = 0; i < Explosions.Length; i++)
	{
		if (Explosions[i].Trigger == triggerDamageType)
			return true;
	}
	
	return false;
}

/**
 * Causes the effect to generate an explosion based on a specific damage type.
 */
simulated function Explode(class<ElementDamageType> triggerDamageType)
{
	
	local int i;
	
	for (i = 0; i < Explosions.Length; i++)
	{
		if (Explosions[i].Trigger == triggerDamageType)
		{
			Spawn(Explosions[i].ExplosionType, self, , Affectee.Location);
			DeactivateEffect();
			return;
		}
	}
}