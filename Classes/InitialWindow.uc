/*******************************************************************************
	InitialWindow

	Creation date: 07/10/2013 16:40
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * An initial window is used to specify what part of the level the players see when a multiplayer game is initially started.  This is used to 
 * allow players time to pick there characters before the game starts.
 */
class InitialWindow extends PlayerStart;

/**
 * The point on the map that the initial window faces.
 */
var() vector LookAt;