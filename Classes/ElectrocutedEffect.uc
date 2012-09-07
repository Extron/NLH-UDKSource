/*******************************************************************************
	ElectrocutedEffect

	Creation date: 08/07/2012 21:50
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ElectrocutedEffect extends StatusEffect;

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=NewStatMod
	MovementMod=0.85
	MobilityMod=0.5
	StabilityMod=0.25
	AccuracyMod=0.5
	End Object
	
	EffectName="Electrocuted"
	HealthDamage=100
	DamageType=class'Arena.ElectrocutedDamageType'
	Duration=5
}