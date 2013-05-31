/*******************************************************************************
	GFx_StatModDisplay

	Creation date: 30/05/2013 21:33
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_StatModDisplay extends GFxObject;

function SetDisplay(WeaponStatModifier mod)
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


function SetStatMod(GFxObject modObj)
{
	ActionScriptVoid("SetStatMod");
}
