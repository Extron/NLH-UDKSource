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
	local float alpha;
	
	super.Tick(dt);
	
	if (ArenaGRI(WorldInfo.GRI) != None)
	{
		r.Pitch = (2 * ArenaGRI(WorldInfo.GRI).WeatherMgr.TimeOfDay + Pi / 2) * RadToUnrRot;
		r.Yaw = RadToUnrRot * Pi / 2;
		SetRotation(r);
		
		alpha = Clamp(ArenaGRI(WorldInfo.GRI).WeatherMgr.CloudCoverage * 5.0, 0.0, 1.0);
		sunColor.r = Lerp(MinSunColor.r, MaxSunColor.r, alpha);
		sunColor.g = Lerp(MinSunColor.g, MaxSunColor.g, alpha);
		sunColor.b = Lerp(MinSunColor.b, MaxSunColor.b, alpha);
		
		LightComponent.SetLightProperties(Lerp(MinSunBrightness, MaxSunBrightness, alpha), sunColor);
		LightComponent.BloomScale = Lerp(MinBloomScale, MaxBloomScale, alpha);
		LightComponent.RadialBlurPercent = Lerp(0.0, 100.0, alpha);
		
		LightComponent.UpdateLightShaftParameters();
	}
}

defaultproperties
{
	MinSunColor=(R=160,G=160,B=180)
	MaxSunColor=(R=255,G=219,B=182)
	MinSunBrightness=0.65
	MaxSunBrightness=5.0
	MinBloomScale=0.75
	MaxBloomScale=4.0
}