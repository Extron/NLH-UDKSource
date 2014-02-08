/*******************************************************************************
	GraphicsSettings

	Creation date: 28/11/2013 00:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GraphicsSettings extends Actor;

/**
 * The x resolution of the game.
*/ 
var int ResX;

/**
 * The y resolution of the game.
 */
var int ResY;

/**
 * The texture quality of the game, ranging from 0 to 2.
 */
var int TextureQuality;

/**
 * The texture quality of the game, ranging from 0 to 2.
 */
var int ShadowQuality;

/**
 * The texture quality of the game, ranging from 0 to 2.
 */
var int ParticleQuality;

/**
 * Indicates that the game should run in fullscreen mode.
 */
var bool Fullscreen;

/**
 * Indicates that the game should use high quality bloom.
 */
var bool HQBloom;

/**
 * Indicates that the game should use motion blur.
 */
var bool MotionBlur;

/**
 * Indicates that the game should use abmient occlusion.
 */
var bool AmbientOcclusion;

/**
 * Indicates that the game should force v-sync.
 */
var bool VSync;

/**
 * Indicates that the game should have dynamic shadows.
 */
var bool DynamicShadows;

function ApplySettings()
{
	ApplyTextureSettings();
	ApplyShadowSettings();
	ApplyParticleSettings();
	
	ConsoleCommand("SETRES" @ string(ResX) $ "x" $ string(ResY) $ (Fullscreen ? "f" : "w"));
	ConsoleCommand("Scale set UseVSync" @ string(VSync));
	ConsoleCommand("Scale set MotionBlur" @ string(MotionBlur));
	ConsoleCommand("Scale set AmbientOcclusion" @ string(AmbientOcclusion));
	ConsoleCommand("Scale set UseHighQualityBloom" @ string(HQBloom));
	ConsoleCommand("Scale set DynamicShadows" @ string(DynamicShadows));
}

function SaveSettings()
{
}

function LoadSettings()
{
	local array<string> settings;
	local string dump;
	local int i;
	
	dump = ConsoleCommand("Scale dump");
	
	`log("=============================================================================================");
	`log("Console command dump");
	`log(dump);
	`log("=============================================================================================");
	
	settings = SplitString(dump, "\n", true);
	
	for (i = 0; i < settings.Length; i++)
	{
		ResX = ScanForInt(settings[i], "ResX", ResX);
		ResY = ScanForInt(settings[i], "ResY", ResY);
		Fullscreen = ScanForBool(settings[i], "Fullscreen", Fullscreen);
		HQBloom = ScanForBool(settings[i], "HighQualityBloom", HQBloom);
		MotionBlur = ScanForBool(settings[i], "MotionBlur", MotionBlur);
		AmbientOcclusion = ScanForBool(settings[i], "AmbientOcclusion", AmbientOcclusion);
		VSync = ScanForBool(settings[i], "UseVSync", VSync);
	}
}

private function ApplyTextureSettings()
{
}

private function ApplyShadowSettings()
{
}

private function ApplyParticleSettings()
{
}

private function int ScanForInt(string line, string setting, int originalValue)
{
	local string result;
	
	result = Repl(Split(line, setting $ "=", true), " ", "");
	
	if (result != "")
	{
		`log("Found graphics setting" @ setting @ "in" @ line);
		
		return int(result);
	}
	else
		return originalValue;
}

private function bool ScanForBool(string line, string setting, bool originalValue)
{
	local string result;
	
	result = Repl(Split(line, setting $ "=", true), " ", "");
	
	if (result != "")
		return bool(result);
	else
		return originalValue;
}