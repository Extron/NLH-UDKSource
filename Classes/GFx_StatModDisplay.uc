/*******************************************************************************
	GFx_StatModDisplay

	Creation date: 30/05/2013 21:33
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_StatModDisplay extends GFxObject;

function SetComponentDisplay(WeaponStatModifier mod)
{
	local GFxObject modObj;
	
	modObj = CreateObject("Object");
	
	modObj.SetFloat("WeightMod", mod.ValueMods[WSVWeight]);	
	modObj.SetFloat("AccuracyMod", mod.ValueMods[WSVAccuracy]);	
	modObj.SetFloat("StabilityMod", mod.ValueMods[WSVStability]);	
	modObj.SetFloat("MobilityMod", mod.ValueMods[WSVMobility]);	
	modObj.SetFloat("RecoilMod", mod.ValueMods[WSVRecoil]);	
	modObj.SetFloat("ZoomMod", mod.ValueMods[WSVZoom]);	
	modObj.SetFloat("RateOfFireMod", mod.ValueMods[WSVRateOfFire]);	
	modObj.SetFloat("RateOfCycleMod", mod.ValueMods[WSVRateOfCycle]);	
	modObj.SetFloat("DamageMod", mod.ValueMods[WSVDamageOutput]);
	
	SetStatMod(modObj);
}

function SetBaseDisplay(WeaponStats stat)
{
	local GFxObject modObj;
	
	modObj = CreateObject("Object");
	
	modObj.SetFloat("Weight", (stat.Values[WSVWeight] > -1.0) ? stat.Values[WSVWeight] : stat.GetGGC(0));
	modObj.SetFloat("Accuracy", (stat.Values[WSVAccuracy] > -1.0) ? stat.Values[WSVAccuracy] : stat.GetGGC(1));	
	modObj.SetFloat("Stability", (stat.Values[WSVStability] > -1.0) ? stat.Values[WSVStability] : stat.GetGGC(2));	
	modObj.SetFloat("Mobility", (stat.Values[WSVMobility] > -1.0) ? stat.Values[WSVMobility] : stat.GetGGC(3));	
	modObj.SetFloat("Recoil", (stat.Values[WSVRecoil] > -1.0) ? stat.Values[WSVRecoil] : stat.GetGGC(4));
	modObj.SetFloat("AccuracyMax", stat.GetGGCMax(1));	
	modObj.SetFloat("StabilityMax", stat.GetGGCMax(2));	
	modObj.SetFloat("MobilityMax", stat.GetGGCMax(3));	
	modObj.SetFloat("RecoilMax", stat.GetGGCMax(4));	
	modObj.SetFloat("Magnification", (stat.Values[WSVZoom] > -1.0) ? stat.Values[WSVZoom] : stat.GetGGC(5));	
	modObj.SetFloat("RateOfFire", (stat.Values[WSVRateOfFire] > -1.0) ? stat.Values[WSVRateOfFire] : stat.GetGGC(6));	
	modObj.SetFloat("RateOfCycle", (stat.Values[WSVRateOfCycle] > -1.0) ? stat.Values[WSVRateOfCycle] : stat.GetGGC(7));	
	modObj.SetFloat("Damage", (stat.Values[WSVDamageOutput] > -1.0) ? stat.Values[WSVDamageOutput] : stat.GetGGC(8));
	
	SetStat(modObj);
}


function SetStatMod(GFxObject modObj)
{
	ActionScriptVoid("SetStatMod");
}

function SetStat(GFxObject modObj)
{
	ActionScriptVoid("SetStat");
}