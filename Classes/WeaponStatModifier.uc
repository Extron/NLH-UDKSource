/*******************************************************************************
	WeaponStatModifier

	Creation date: 23/08/2012 16:22
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponStatModifier extends Object
	dependson(WeaponStats);

/** A list of all mods, indexed by enum, for the weapon stats. */
var array<float> ValueMods;

defaultproperties
{
	ValueMods[WSVWeight]=1
	ValueMods[WSVAccuracy]=1
	ValueMods[WSVStability]=1
	ValueMods[WSVMobility]=1
	ValueMods[WSVRecoil]=1
	ValueMods[WSVZoom]=1
	ValueMods[WSVRateOfFire]=1
	ValueMods[WSVRateOfCycle]=1
	ValueMods[WSVDamageOutput]=1
	ValueMods[WSVCoolDownRate]=1
	ValueMods[WSVOverheatDelay]=1
	ValueMods[WSVHeatCost]=1
	ValueMods[WSVADSAccuracy]=1
}