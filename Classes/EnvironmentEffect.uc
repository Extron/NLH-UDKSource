/*******************************************************************************
	EnvironmentEffect

	Creation date: 08/07/2012 19:37
	Copyright (c) 2012, Strange Box Software
*******************************************************************************/

/* 
 * This is the environment version of a status effect, and keeps track of elemental effects to environment objects. 
 */
class EnvironmentEffect extends EntityEffect;


/**
 * The type of damage that this effect causes to things that come in contact with the environment object.
 */
var array<class<ElementDamageType> > DamageTypes;

/**
 * The properties that the environment object must have to have the effect.
 */
var array<string> Properties;


simulated function DeactivateEffect()
{
	if (IEnvObj(Affectee) != None)
		IEnvObj(Affectee).RemoveEffect(self);
		
	super.DeactivateEffect();
}

/** 
 * Causes the effect to target another actor.
 */
simulated function AffectTarget(Actor target)
{
	local int i;
	
	for (i = 0; i < DamageTypes.Length; i++)
		target.TakeDamage(0, Instigator.Controller, target.Location, vect(0, 0, 0), DamageTypes[i]);
}