/*******************************************************************************
	GFx_SBBOptions

	Creation date: 04/08/2013 15:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_SBBOptions extends GFx_Menu;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The parent menu that this is displaying over.
 */
var GFx_SoloBotBattle Parent;

/**
 * The cursor of the menu.
 */
var GFxObject Cursor;


function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
	
	Advance(0);

	Cursor = GetVariableObject("_root.cursor");
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	LoadSettings();
	
	return true;
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function CloseAnimCompleted()
{
	Back();
}

function ButtonClicked(string label)
{
	if (label == "Cancel")
	{
		CloseMenu();
	}
	else if (label == "Accept")
	{
		SaveSettings();
		CloseMenu();
	}
}

function Back()
{
	Pawn.SetMenu(Parent);
	Close();
}

function SaveSettings()
{
	local GFxObject settingsObj;
	local GISettings_BotBattle settings;
	
	settingsObj = GetSettings();
	
	settings = new class'GISettings_BotBattle';
	
	settings.TimeLimit = settingsObj.GetFloat("timeLimit");
	settings.RespawnTime = settingsObj.GetFloat("respawnTime");
	settings.Lives = settingsObj.GetInt("lives");
	
	settings.StartTime = settingsObj.GetFloat("timeOfDay");
	settings.StartTemperature = settingsObj.GetFloat("temperature");
	settings.StartCloudCoverage = settingsObj.GetFloat("cloudCoverage");
	settings.StartWeatherIntensity = settingsObj.GetFloat("weatherIntensity");
	settings.DayCycleProgression = settingsObj.GetBool("progressDay");
	settings.WeatherProgression = settingsObj.GetBool("progressWeather");
	
	Parent.Settings = settings;
}

function LoadSettings()
{
	local GFxObject settingsObj;
	local GISettings_BotBattle settings;
	
	settings = Parent.Settings;
	settingsObj = CreateObject("Object");

	settingsObj.SetFloat("timeLimit", settings.TimeLimit);
	settingsObj.SetFloat("respawnTime", settings.RespawnTime);
	settingsObj.SetInt("lives", settings.Lives);
	
	settingsObj.SetFloat("timeOfDay", settings.StartTime);
	settingsObj.SetFloat("temperature", settings.StartTemperature);
	settingsObj.SetFloat("cloudCoverage", settings.StartCloudCoverage);
	settingsObj.SetFloat("weatherIntensity", settings.StartWeatherIntensity);
	settingsObj.SetBool("progressDay", settings.DayCycleProgression);
	settingsObj.SetBool("progressWeather", settings.WeatherProgression);
	
	SetSettings(settingsObj);
}

function GFxObject GetSettings()
{
	return ActionScriptObject("_root.GetSettings");
}

function SetSettings(GFxObject settings)
{
	ActionScriptVoid("_root.SetSettings");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.SBBOptions'
	
	bCaptureMouseInput=true
	bCaptureInput=true
}