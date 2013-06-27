/*******************************************************************************
	Ab_Earthquake

	Creation date: 19/06/2013 19:05
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Earthquake extends ArenaAbility;


/**
 * The volume that represents where the Earthquake effect occurs.  The outer volume is where shaking happens without damage.
 */
var Ab_EarthquakeVolume Volume;

/**
 * The class of the inner volume to spawn.  This can be set in subclasses to specify specific volumes.
 */
var class<Ab_EarthquakeVolume> VolumeClass;

/**
 * The duration of the earthquake.
 */
var float EarthquakeDuration;


simulated function CustomFire()
{
	if (!IsHolding)
	{
		`log("Spawning earthquake area");
		
		if (Volume != None)
			Volume.Destroy();
			
		Volume = spawn(VolumeClass, Owner, , Owner.Location - vect(0, 0, 64));
		Volume.CShake.OscillationDuration = EarthquakeDuration;
		Volume.DamagePerSecond = ArenaPawn(Owner).Stats.GetMeleeDamage() / EarthquakeDuration;
		
		SetTimer(EarthquakeDuration, false, 'EndEarthquake');
	}
}

simulated function EndEarthquake()
{
	Volume.Destroy();
}

defaultproperties
{	
	VolumeClass=class'Arena.Ab_EarthquakeVolume'
	
	WeaponFireTypes[0]=EWFT_Custom
	
	EarthquakeDuration=5
	
	CoolDown=5
	EnergyCost=500
	AbilityName="Earthquake"
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}