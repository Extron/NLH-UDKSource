/*******************************************************************************
	Electricity

	Creation date: 24/09/2012 15:00
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PC_Electricity extends PlayerClass
	dependson(PlayerStats);

/**
 * Sets the weather stat mod for maximum snow levels.
 */
function SetMaxSnowMod(float intensity)
{
	WeatherMod.ValueMods[PSVEnergyRegenRate] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenRate] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVStaminaRegenRate] = 0.5 * intensity;
	WeatherMod.ValueMods[PSVGlobalDamageInput] = 1.25 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenDelay] = 1.5 * intensity;
	WeatherMod.ValueMods[PSVEnergyRegenDelay]= 1.25 * intensity;
	WeatherMod.ValueMods[PSVStaminaRegenDelay] = 1.25 * intensity;
	WeatherMod.ValueMods[PSVEnergyCostFactor] = 0.5 * intensity;
	WeatherMod.ValueMods[PSVAbilityCooldownFactor] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVMobility] = 0.85 * intensity;
}

/**
 * Sets the weather stat mod for maximum rain levels.
 */
function SetMaxRainMod(float intensity)
{
	WeatherMod.ValueMods[PSVGlobalDamageOutput] = 1.25 * intensity;
	WeatherMod.ValueMods[PSVGlobalDamageInput] = 1.15 * intensity;
	WeatherMod.ValueMods[PSVEnergyRegenDelay] = 0.75 * intensity;
	WeatherMod.ValueMods[PSVEnergyDamageFactor] = 1.5 * intensity;
	WeatherMod.ValueMods[PSVAbilityCooldownFactor] = 0.85 * intensity;
}

defaultproperties
{
	ClassName="Electricity"
	
	Trees[0]=class'Arena.AT_ShockShort'
	Trees[1]=class'Arena.AT_ShockMedium'
	Trees[2]=class'Arena.AT_Repulsion'
	Trees[3]=class'Arena.AT_LightningBolt'
	Trees[4]=class'Arena.AT_Deflection'
	Trees[5]=class'Arena.AT_EMP'
	
	Begin Object Name=NewMod
		ValueMods[PSVAccuracy]=1.1
		ValueMods[PSVMobility]=1.1
		ValueMods[PSVMovement]=1.05
	End Object
}