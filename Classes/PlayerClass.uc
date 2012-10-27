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
 * The stat modifier of class.
 */
var PlayerStatModifier Mod;

/**
 * The display name of the class.
 */
var string ClassName;