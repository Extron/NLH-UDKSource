/*******************************************************************************
	Ab_StunningEarthquakeVolume

	Creation date: 23/06/2013 02:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_StunningEarthquakeVolume extends Ab_EarthquakeVolume;

/**
 * The stunning effect that pawns receive when inside this volume.
 */
var class<SE_Stun> StunEffect;

var float OldCounter;

var bool CanStun;

simulated function Tick(float dt)
{
	super.Tick(dt);
		
	if (Counter - OldCounter > 1)
	{
		OldCounter = Counter;
		CanStun = true;
	}
	
	if (CanStun)
	{
		Stun();
		CanStun = false;
	}
}

simulated function Stun()
{
	local ArenaPawn pawn;
	local SE_Stun effect;
	
	foreach WorldInfo.AllPawns(class'Arena.ArenaPawn', pawn, Location, DamageRadius)
	{
		if (!pawn.HasStatus(StunEffect.default.EffectName))
		{
			effect = Spawn(StunEffect, pawn);
			pawn.AddEffect(effect);
		}
	}
}

defaultproperties
{
	StunEffect=class'Arena.SE_Stun'
	CanStun=true
}
