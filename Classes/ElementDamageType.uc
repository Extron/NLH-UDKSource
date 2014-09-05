/*******************************************************************************
	AbilityDamageType

	Creation date: 24/06/2012 17:56
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ElementDamageType extends ArenaDamageType;

/**
 * A list of the entity effects that the ability attaches to the target. 
 */
var Array<class<EntityEffect> > EntityEffects;