/*******************************************************************************
	Ab_ThunderRush

	Creation date: 25/08/2012 19:07
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_ThunderRush extends Ab_ShockShort;

simulated function ProcessInstantHit(byte mode, ImpactInfo impact, optional int numHits)
{
	local vector vel;
	
	super.ProcessInstantHit(mode, impact, numHits);
	
	`log("Processing hit:  HitActor" @ impact.HitActor);
	
	if (ArenaPawn(impact.HitActor) != None)
	{
		vel = Normal(impact.HitLocation - Instigator.Location) * vect(1, 1, 0.15);
		
		if (ArenaPawn(Instigator).Physics != PHYS_Falling)
		{
			ArenaPawn(Instigator).AddVelocity(vel * 5000, vect(0, 0, 0), None);
		}
		else
		{
			ArenaPawn(Instigator).AddVelocity(vel * 1500, vect(0, 0, 0), None);
		}
	}
}

defaultproperties
{
	FireSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	AbilityName="Thunder Rush"
}