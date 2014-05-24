/*******************************************************************************
	SunLight

	Creation date: 23/12/2012 01:41
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SunLight extends DominantDirectionalLightMovable;

/** The minimum color of the sun at full cloud coverage. */
var color MinSunColor;

/** The maximum color of the sun at full cloud coverage. */
var color MaxSunColor;

/** The minimum brightness of the sun at full cloud coverage. */
var float MinSunBrightness;

/** The maximum brightness of the sun at no cloud coverage. */
var float MaxSunBrightness;

var float MinBloomScale;

var float MaxBloomScale;

simulated function Tick(float dt)
{
	local rotator r;
	local color sunColor;
	local float brightness;
	local float bloom;
	local float radial;
	local float alpha;
	local float beta;
	
	super.Tick(dt);
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		r.Pitch = (2 * ArenaGRI(WorldInfo.GRI).WeatherMgr.TimeOfDay + Pi / 2) * RadToUnrRot;
		r.Yaw = RadToUnrRot * Pi / 2;
		SetRotation(r);
		
		alpha = FClamp(ArenaGRI(WorldInfo.GRI).WeatherMgr.CloudCoverage * 3.0, 0.0, 1.0);
		sunColor.r = Lerp(MinSunColor.r, MaxSunColor.r, alpha);
		sunColor.g = Lerp(MinSunColor.g, MaxSunColor.g, alpha);
		sunColor.b = Lerp(MinSunColor.b, MaxSunColor.b, alpha);

		beta = FClamp(-3 * cos(2 * ArenaGRI(WorldInfo.GRI).WeatherMgr.TimeOfDay) + 1, 0.0, 1.0);
		
		brightness = Lerp(0.0, Lerp(MinSunBrightness, MaxSunBrightness, alpha), beta);
		bloom = Lerp(0.0, Lerp(MinBloomScale, MaxBloomScale, alpha), beta);
		radial = Lerp(0.0, Lerp(0.0, 100.0, alpha), beta);
		
		LightComponent.SetLightProperties(brightness, sunColor);
		LightComponent.BloomScale = bloom;
		LightComponent.RadialBlurPercent = radial;
		
		LightComponent.UpdateLightShaftParameters();
	}
}

defaultproperties
{
	Begin Object Name=DominantDirectionalLightComponent0
		WholeSceneDynamicShadowRadius=4096
	End Object

	MinSunColor=(R=160,G=160,B=180)
	MaxSunColor=(R=255,G=219,B=182)
	MinSunBrightness=0.65
	MaxSunBrightness=4.0
	MinBloomScale=0.75
	MaxBloomScale=4.0
}