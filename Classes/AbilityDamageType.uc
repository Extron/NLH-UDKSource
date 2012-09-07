/*******************************************************************************
	AbilityDamageType

	Creation date: 24/06/2012 17:56
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AbilityDamageType extends DamageType;

/* A list of the status effects that the ability attaches to the target. */
var Array<class<StatusEffect> > StatusEffects;

/* A list of the environment effects that the ability attaches to the target. */
var Array<class<EnvironmentEffect> > EnvironmentEffects;