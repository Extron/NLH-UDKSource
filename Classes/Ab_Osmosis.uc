/******************************************************************************
	Ab_Osmosis
	
	Creation date: 20/04/2013 21:49
	Copyright (c) 2013, Owner
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_Osmosis extends ArenaAbility;

/* The PlayerStatModifier */
var PlayerStatModifier StatMod;

/* The boolean that keeps track of if the StatMod has already been added or
	not */
var bool HasModifier;

simulated function PostBeginPlay()
{
	StatMod.ValueMods[PSVEnergyRegenRate] = 1.5;
	StatMod.ValueMods[PSVStaminaRegenRate] = 1.5;
}

simulated function Tick(float dt)
{
	if (ArenaGRI(WorldInfo.GRI) == None || ArenaGRI(WorldInfo.GRI).WeatherMgr == None)
		return;

	// Is it raining?
	if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining) {
		// Is the Instigator in rain & doesn't already have the modifier?
		if ((!HasModifier) && (ArenaPawn(Instigator).InWeatherVolume)) {
			`log("Adding osmosis buff.");
			ArenaPawn(Instigator).Stats.AddModifier(StatMod);
			HasModifier = true;
		}
		else if ((HasModifier) && (!ArenaPawn(Instigator).InWeatherVolume)) {
			`log("Removing osmosis buff.");
			ArenaPawn(Instigator).Stats.RemoveModifier(StatMod);
			HasModifier = false;
		}
	}
	else if (HasModifier) {
		`log("Removing osmosis buff.");
		ArenaPawn(Instigator).Stats.RemoveModifier(StatMod);
		HasModifier = false;
	}
}

defaultproperties
{
	AbilityName="Osmosis"
	
	Begin Object Class=PlayerStatModifier Name=NewMod
		StatMod.ValueMods[PSVEnergyRegenRate]=1.5
		StatMod.ValueMods[PSVStaminaRegenRate]=1.5
	End Object
	
	HasModifier=false
	
	IsPassive=true
}