/*******************************************************************************
	AbilityTree

	Creation date: 09/09/2013 16:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Provides a simple representation of an ability tree, which contains a list of tiered abilities.
 */
class AbilityTree extends Object;


/**
 * The abilities that are in the tree.  These are organized in a breadth first manner.
 */
var array<class<ArenaAbility> > Abilities;

/**
 * Each element in this array corresponds to an ability, and indicates whether the player's character has unlocked that selected ability.
 */
var array<bool> UnlockStatus;

/**
 * The name of the ability tree.
 */
var string TreeName;

/**
 * The icon of the tree to use.
 */
var string TreeIcon;


defaultproperties
{
	UnlockStatus[0]=false
	UnlockStatus[1]=false
	UnlockStatus[2]=false
	UnlockStatus[3]=false
	UnlockStatus[4]=false
	UnlockStatus[5]=false
	UnlockStatus[6]=false
}