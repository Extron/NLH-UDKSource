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

simulated function ActivateEffect(Actor target)
{
	super.ActivateEffect(target);
	
	if (ArenaPawn(target) != None)
	{
		if (ArenaPawn(target).Sensor != None)
			ArenaPawn(target).Sensor.AddGhost(GhostDuration);
	}
}

defaultproperties
{	
	EffectName="Disoriented"
	Duration=15
	Group=EG_Electromagnetism
	
	GhostDuration=15
}