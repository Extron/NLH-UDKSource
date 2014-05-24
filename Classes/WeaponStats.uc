/*******************************************************************************
	WeaponStats

	Creation date: 23/08/2012 16:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponStats extends Component;

enum WStatValues
{
	WSVWeight,
	WSVAccuracy,
	WSVStability,
	WSVMobility,
	WSVRecoil,
	WSVZoom,
	WSVRateOfFire,
	WSVRateOfCycle,
	WSVDamageOutput,
	WSVCoolDownRate,
	WSVOverheatDelay,
	WSVHeatCost,
	WSVADSAccuracy,
};

/** A list of modifiers to modify the weapon stats with. */
var array<WeaponStatModifier> Modifiers;

/** A list of values, indexed by enum, for the stats. */
var array<float> Values;

/** Stores the starting values of the stats. */
var array<float> DefaultValues;

/** The weapon that these stats belong to. */
var ArenaWeapon Weapon;


simulated function Initialize(ArenaWeapon weap)
{
	Weapon = weap;
	InitValues();
	ComputeStats();
}

/**
 * Gets the multiplicitave factor to change the reload speed by.
 */
simulated function float GetReloadSpeed()
{
	return 1;
}

/**
 * Gets the multiplicitave factor to change the cycle speed by.
 */
simulated function float GetCycleSpeed()
{
	return 1;
}

/**
 * Gets the multiplicitave factor to change the equipping speed by.
 */
simulated function float GetEquipSpeed()
{
	return 1;
}

/**
 * Gets a rotator used to shift the weapon's aim trajectory to simulate inaccuracy.
 */
simulated function rotator GetInaccuracyShift()
{
	local vector x, y, z;
	local rotator base;
	local float yShift, zShift, factor;
	
	base = Weapon.Instigator.GetBaseAimRotation();
	GetAxes(base, x, y, z);
	
	//Ok, so now we have the local axes of the bullet projectile. The x axis is in the direction
	//that the bullet is traveling, and the y and z axes form the plane orthogonal to that trajectory.
	//We will only ever modify y and z, since that is the only direction it makes sense to shift in.
	
	yShift = (FRand() - 0.5) * 0.2;
	zShift = (FRand() - 0.5) * 0.2;
	
	factor = class'GlobalGameConstants'.static.GetFactorMin("Accuracy Shift") * (1 - 1 / fmax(class'GlobalGameConstants'.static.NormalizedStat("Weapon Accuracy", Values[WSVAccuracy]), 0.001)) + 
			 class'GlobalGameConstants'.static.GetFactorMax("Accuracy Shift") * (1 / fmax(class'GlobalGameConstants'.static.NormalizedStat("Weapon Accuracy", Values[WSVAccuracy]), 0.001));
	
	factor *= ArenaPawn(Weapon.Instigator).Stats.GetInaccuracyFactor();
	factor += class'GlobalGameConstants'.static.NormalizedStat("Bloom", Weapon.Bloom);
	
	if (ArenaPawn(Weapon.Instigator).ADS)
		factor *= Values[WSVADSAccuracy]; // I actually think this should be dependant on the type of optics that is used.

	return rotator(x + yShift * factor * y + zShift * factor * z);
}

/**
 * This computed the amount of bloom to add to the weapon's accuracy factor per shot.  It is mostly reliant
 * on the player's and the weapon's Stability factor.
 */
simulated function float GetBloomCost()
{
	local float x;
	
	x = class'GlobalGameConstants'.static.NormalizedStat("Weapon Stability", Values[WSVStability]) * class'GlobalGameConstants'.static.NormalizedStat("Weapon Recoil", Values[WSVRecoil]);

	return ArenaPawn(Weapon.Instigator).Stats.GetBloomFactor() * (class'GlobalGameConstants'.static.GetFactorMin("Bloom Cost") * x + class'GlobalGameConstants'.static.GetFactorMax("Bloom Cost") * (1 - x));
}

simulated function float GetHeatCost()
{
	return FMax(Values[WSVHeatCost], 0);
}

simulated function float GetCooldownRate()
{
	return FMax(Values[WSVCoolDownRate], 0);
}

simulated function float GetOverheatDelay()
{
	return FMax(Values[WSVOverheatDelay], 0);
}
 
/**
 * Gets the damage modifer of the weapon, which is based on all of its stats.
 */
simulated function float GetDamageModifier()
{
	return 1;
}

simulated function AddModifier(WeaponStatModifier mod)
{
	Modifiers.AddItem(mod);
	
	ComputeStats();
}

simulated function RemoveModifier(WeaponStatModifier mod)
{
	Modifiers.RemoveItem(mod);
	
	ComputeStats();
}

simulated function InitValues()
{
	local int i;
	
	for (i = 0; i < Values.Length; i++)
	{
		if (Values[i] == -1)
			DefaultValues[i] = GetGGC(i);
		else
			DefaultValues[i] = Values[i];	
	}
}

simulated function float GetGGC(int i)
{
	switch (i)
	{
	case 0:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Weight");
		
	case 1:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Accuracy");
		
	case 2:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Stability");
		
	case 3:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Mobility");
		
	case 4:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Recoil");
		
	case 5:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Zoom");
		
	case 6:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Rate of Fire");
		
	case 7:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Rate of Cycle");
		
	case 8:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Damage Output");
		
	case 9:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Cool Down Rate");
		
	case 10:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Overheat Delay");
		
	case 11:
		return class'GlobalGameConstants'.static.GetStatDefault("Weapon Heat Cost");
		
	case 12:
		return class'GlobalGameConstants'.static.GetStatDefault("ADS Accuracy");
		
	default:
		return 0;
	}
}

simulated function float GetGGCMax(int i)
{
	switch (i)
	{
	case 0:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Weight");
		
	case 1:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Accuracy");
		
	case 2:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Stability");
		
	case 3:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Mobility");
		
	case 4:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Recoil");
		
	case 5:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Zoom");
		
	case 6:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Rate of Fire");
		
	case 7:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Rate of Cycle");
		
	case 8:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Damage Output");
		
	case 9:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Cool Down Rate");
		
	case 10:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Overheat Delay");
		
	case 11:
		return class'GlobalGameConstants'.static.GetStatMax("Weapon Heat Cost");
		
	case 12:
		return class'GlobalGameConstants'.static.GetStatMax("ADS Accuracy");
		
	default:
		return 0;
	}
}

simulated function ResetStats()
{
	local int i;
	
	for (i = 0; i < Values.Length; i++)
	{
		Values[i] = DefaultValues[i];
	}
}

simulated function ComputeStats()
{
	local WeaponStatModifier statMod;
	local int i, j;
	
	ResetStats();
	
	for (i = 0; i < Modifiers.Length; i++)
	{
		statMod = Modifiers[i];
		
		for (j = 0; j < Values.Length; j++)
		{
			Values[j] *= statMod.ValueMods[j];
		}
	}
}

defaultproperties
{
	Values[WSVWeight]=-1
	Values[WSVAccuracy]=-1
	Values[WSVStability]=-1
	Values[WSVMobility]=-1
	Values[WSVRecoil]=-1
	Values[WSVZoom]=-1
	Values[WSVRateOfFire]=-1
	Values[WSVRateOfCycle]=-1
	Values[WSVDamageOutput]=-1
	Values[WSVCoolDownRate]=-1
	Values[WSVOverheatDelay]=-1
	Values[WSVHeatCost]=-1
	Values[WSVADSAccuracy]=-1
}