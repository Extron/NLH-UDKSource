/*******************************************************************************
	ParametrizedSkyLightComponent

	Creation date: 29/05/2014 22:18
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A parametrized ambient light component that blends between a default color and brightness and a overlaying color and brightness via a 
 * linear interpolating parameter.
 */
class ParametrizedSkyLightComponent extends SkyLightComponent;

/**
 * The light's default color.
 */
var color DefaultLightColor;

/**
 * The light's default brightness.
 */
var float DefaultBrightness;

/**
 * The color that is being overlayed.
 */
var color OverlayLightColor;

/**
 * The brightness that is being overlayed.
 */
var float OverlayBrightness;

/**
 * The parameter used to interpolate between the default and overlay light characteristics.
 */
var float Parameter;

function SetOverlayProperties(color newColor, float newBrightness)
{
	OverlayLightColor = newColor;
	OverlayBrightness = newBrightness;
	
	UpdateLightProperties();
}

function SetDefaultProperties(color newColor, float newBrightness)
{
	DefaultLightColor = newColor;
	DefaultBrightness = newBrightness;
	
	UpdateLightProperties();
}

function SetParameter(float newParameter)
{
	Parameter = FClamp(newParameter, 0, 1);
	
	UpdateLightProperties();
}

function UpdateLightProperties()
{
	SetLightProperties(Lerp(DefaultBrightness, OverlayBrightness, Parameter), ColorLerp(DefaultLightColor, OverlayLightColor, Parameter));
}

function string ColorToString(color C)
{
	return "R:" $ C.r @ "G:" $ C.g @ "B:" $ C.b @ "A:" $ C.a;
}

function color ColorLerp(color A, color B, float alpha)
{
	local color newColor;
	
	newColor.r = Lerp(A.r, B.r, alpha);
	newColor.g = Lerp(A.g, B.g, alpha);
	newColor.b = Lerp(A.b, B.b, alpha);
	newColor.a = Lerp(A.a, B.a, alpha);
	
	return newColor;
}