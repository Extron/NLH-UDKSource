/*******************************************************************************
	PlayerClass

	Creation date: 24/09/2012 13:40
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Stores information on the player's class.
 */
class PlayerClass extends Object
	abstract;


/**
 * The player controller that owns the class.
 */
var ArenaPlayerController Owner;

/**
 * The stat modifier of class.
 */
var PlayerStatModifier Mod;

/**
 * The modifier to apply during inclement weather.
 */
var PlayerStatModifier WeatherMod;

/**
 * The display name of the class.
 */
var string ClassName;


/**
 * Sets the weather stat mod for maximum snow levels.
 */
function SetSnowMod(float intensity);

/**
 * Sets the weather stat mod for maximum rain levels.
 */
function SetRainMod(float intensity);

/**
 * Scales the weather stat modifier according to the weather intensity.
 */
function ScaleWeatherMod(WeatherManager weather)
{
	if (weather.Snowing)
		SetSnowMod(weather.WeatherIntensity);
	else if (weather.Raining)
		SetRainMod(weather.WeatherIntensity);
}

function ActivateWeatherMod(WeatherManager weather)
{
	ScaleWeatherMod(weather);
	
	ArenaPawn(Owner.Pawn).AddStatMod(WeatherMod);
}

function DeactivateWeatherMod()
{
	ArenaPawn(Owner.Pawn).RemoveStatMod(WeatherMod);
}


defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=NewMod
	End Object
	Mod=NewMod
	
	Begin Object Class=PlayerStatModifier Name=NewWMod
	End Object
	WeatherMod=NewWMod
}