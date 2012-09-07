/*******************************************************************************
	EffectDamageType

	Creation date: 01/07/2012 11:43
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* The base for environmental effect damage types, such as the charged effect, or the on fire effect. */
class EffectDamageType extends DamageType;

/* The duration that the effect lasts. */
var float Duration;

defaultproperties
{
	bCausedByWorld=true
}