/*******************************************************************************
	ArenaDamageType

	Creation date: 18/08/2013 03:20
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This subclass of DamageType allows a point value to be assigned to a damage type.
 */
class ArenaDamageType extends DamageType;

/**
 * The amount of points allotted to players when they kill another pawn with this damage type.
 */
var float Points;

/**
 * The amount of recoil a player receives when hit by this damage type.
 */
var float Recoil;

/**
 * The string to display when an enemy is killed with this damage type (ie "Bot electrocuted").
 */
var string ActionString;

/**
 * The color to display when drawing the damage type's action string.
 */
var int DisplayColor;

defaultproperties
{
	DisplayColor=0xFFFFFF
}