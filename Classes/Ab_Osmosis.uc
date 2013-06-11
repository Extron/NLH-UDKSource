/******************************************************************************
	Ab_Osmosis
	
	Creation date: 20/04/2013 21:49
	Copyright (c) 2013, Owner
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_Osmosis extends ArenaAbility
	dependson(PlayerStatModifier);

/* The PlayerStatModifier */
var PlayerStatModifier StatsModifier;

/* The boolean that keeps track of if the StatsModifier has already been added or
	not */
var bool HasModifier;

simulated function PostBeginPlay()
{
	StatsModifier.ValueMods[PSVEnergyRegenRate] = 1.5;
	StatsModifier.ValueMods[PSVStaminaRegenRate] = 1.5;
}

simulated function Tick(float dt)
{
	if (ArenaGRI(WorldInfo.GRI) == None || ArenaGRI(WorldInfo.GRI).WeatherMgr == None)
		return;

	// Is it raining?
	if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining) {
		// Is the Instigator in rain & doesn't already have the Modifier?
		if ((!HasModifier) && (ArenaPawn(Instigator).InWeatherVolume)) {
			`log("Adding osmosis buff.");
			ArenaPawn(Instigator).Stats.AddModifier(StatsModifier);
			HasModifier = true;
		}
		else if ((HasModifier) && (!ArenaPawn(Instigator).InWeatherVolume)) {
			`log("Removing osmosis buff.");
			ArenaPawn(Instigator).Stats.RemoveModifier(StatsModifier);
			HasModifier = false;
		}
	}
	// Remove if it is not raining
	else if (HasModifier) {
		`log("Removing osmosis buff.");
		ArenaPawn(Instigator).Stats.RemoveModifier(StatsModifier);
		HasModifier = false;
	}
}

defaultproperties
{
	AbilityName="Osmosis"
	
	Begin Object Class=PlayerStatModifier Name=NewStatMod
	End Object
	StatsModifier=NewStatMod
	
	HasModifier=false
	
	IsPassive=true
}