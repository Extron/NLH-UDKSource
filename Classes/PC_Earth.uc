/*******************************************************************************
	PC_Earth

	Creation date: 24/09/2012 15:14
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PC_Earth extends PlayerClass;

/**
 * Sets the weather stat mod for maximum snow levels.
 */
function SetSnowMod(float intensity)
{
	WeatherMod.ValueMods[PSVEnergyRegenRate] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenRate] = 0.5 * intensity;
	WeatherMod.ValueMods[PSVStaminaRegenRate] = 0.75 * intensity;
	WeatherMod.ValueMods[PSVHealthRegenDelay] = 1.25 * intensity;
	WeatherMod.ValueMods[PSVAbilityCooldownFactor] = 0.25 * intensity;
	WeatherMod.ValueMods[PSVMobility] = 0.95 * intensity;
}

/**
 * Sets the weather stat mod for maximum rain levels.
 */
function SetMaxRainMod(float intensity)
{
	WeatherMod.ValueMods[PSVGlobalDamageOutput] = 0.75 * intensity;
	WeatherMod.ValueMods[PSVGlobalDamageInput] = 1.35 * intensity;
	WeatherMod.ValueMods[PSVEnergyRegenDelay] = 1.25 * intensity;
	WeatherMod.ValueMods[PSVAbilityCooldownFactor] = 0.85 * intensity;
}

defaultproperties
{
	ClassName="Earth"
	
	Trees[0]=class'Arena.AT_Earthquake'
	Trees[1]=class'Arena.AT_RockWall'
	Trees[2]=class'Arena.AT_Sand'
	Trees[3]=class'Arena.AT_StoneFlesh'
	Trees[4]=class'Arena.AT_Pedestal'
	
	Begin Object Name=NewMod
		ValueMods[PSVMaxStamina]=1.05
		ValueMods[PSVGlobalDamageInput]=0.95
		ValueMods[PSVStability]=1.1
		ValueMods[PSVStaminaRegenRate]=1.05
	End Object
}