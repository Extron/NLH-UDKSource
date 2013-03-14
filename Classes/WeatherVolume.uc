/*******************************************************************************
	WeatherVolume

	Creation date: 12/03/2013 13:21
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A weather volume dictates where wheather effects like snow and rain can spawn.
 */
class WeatherVolume extends Volume
	placeable;

/**
 * The density of the weather planes for this volume.  Note that this should not be set too high, or 
 * the game will suffer poor performance.
 */
var() float WeatherPlaneDensity;

/**
 * The density of the snow mounds for this volume.
 */
var() float SnowMoundDensity;

/**
 * Indicates that snow mounds can be spawned in this area.
 */
var() bool SpawnSnowMounds;

defaultproperties
{
	BrushColor=(R=0,G=0,B=255,A=255)
}