/*******************************************************************************
	AbilityExplosion

	Creation date: 01/07/2014 19:44
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * An explosion caused by the combination of a status effect with an ability damage type.
 */
class AbilityExplosion extends Actor;

/**
 * The damage type of the explosion.
 */
var class<AbilityDamageType> DamageType;

/**
 * The explosion particle system template.
 */
var ParticleSystem ExlposionTemplate;

