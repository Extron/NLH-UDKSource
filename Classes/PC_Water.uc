/*******************************************************************************
	PC_Water

	Creation date: 24/09/2012 15:09
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PC_Water extends PlayerClass
	dependson(PlayerStats);

/**
 * Sets the weather stat mod for maximum snow levels.
 */
function SetSnowMod(float intensity)
{
	WeatherMod.ValueMods[PSVEnergyRegenRate] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenRate] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVStaminaRegenRate] = 0.5 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenDelay] = 1.25 * intensity;
	WeatherMod.ValueMods[PSVAbilityCooldownFactor] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVMobility] = 0.95 * intensity;
}

/**
 * Sets the weather stat mod for maximum rain levels.
 */
function SetRainMod(float intensity)
{
	WeatherMod.ValueMods[PSVMobility] = 1.5 * intensity;
	WeatherMod.ValueMods[PSVMaxHealth] = 1.2 * intensity;
	WeatherMod.ValueMods[PSVMaxEnergy] = 1.5 * intensity;
	WeatherMod.ValueMods[PSVGlobalDamageOutput] = 1.75 * intensity;
	WeatherMod.ValueMods[PSVGlobalDamageInput] = 0.65 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenDelay] = 0.5 * intensity;
	WeatherMod.ValueMods[PSVEnergyRegenDelay] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVEnergyCostFactor] = 0.5 * intensity;
	WeatherMod.ValueMods[PSVAbilityCooldownFactor] = 0.85 * intensity;
}

defaultproperties
{
	ClassName="Water"
	
	Trees[0]=class'Arena.AT_Bubble'
	Trees[1]=class'Arena.AT_Osmosis'
	
	Begin Object Name=NewMod
		ValueMods[PSVEnergyRegenRate]=1.1
		ValueMods[PSVMobility]=1.1
		ValueMods[PSVAbilityCooldownFactor]=0.85
	End Object
}
