/*******************************************************************************
	ArenaLightActor

	Creation date: 09/09/2014 00:24
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A lighting actor that interacts better with the dynamic aspects of a level.
 */
class ArenaLightActor extends Light implements(IToggleableObject)
	ClassGroup(Lights)
	placeable;
	
var(ArenaLight) bool On;

/**
 * Toggles the light, turning it on or off.
 */
simulated function Toggle()
{
	On = !On;

	LightComponent.SetEnabled(On);
}

defaultproperties
{
	bStatic=false
	bHidden=false
	bNoDelete=false
	bMovable=true
	bEdShouldSnap=true
	
	On=true
}