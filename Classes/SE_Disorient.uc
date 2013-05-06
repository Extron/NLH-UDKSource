/*******************************************************************************
	SE_Disorient

	Creation date: 21/04/2013 20:20
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A status effect that adds a random ghost to any player sensors.
 */
class SE_Disorient extends StatusEffect;


/**
 * The length that a ghost will last in a pawn's sensors.
 */
var float GhostDuration;


simulated function float GetHealthDamage(float dt)
{
	return 0;
}

simulated function float GetEnergyDamage(float dt)
{
	return 0;
}

simulated function float GetStaminaDamage(float dt)
{
	return 0;
}

simulated function bool ApplyHealthDamage()
{
	return false;
}

simulated function bool ApplyEnergyDamage()
{
	return false;
}

simulated function bool ApplyStaminaDamage()
{
	return false;
}

simulated function ActivateEffect(ArenaPawn pawn)
{
	super.ActivateEffect(pawn);
	
	if (pawn.Sensor != None)
	{
		pawn.Sensor.AddGhost(duration);
	}
}

defaultproperties
{	
	EffectName="Disoriented"
	Duration=15
	SEGroup=SEG_Electromagnetism
	
	InitialHealthDamage=0
	InitialEnergyDamage=0
	InitialStaminaDamage=0
	
	HealthDamage=0
	EnergyDamage=0
	StaminaDamage=0
	
	DurationWeight=0
	HealthDamageWeight=0
	EnergyDamageWeight=0
	StaminaDamageWeight=0
	IHDWeight=0
	IEDWeight=0
	ISDWeight=0
	
	GhostDuration=15
}