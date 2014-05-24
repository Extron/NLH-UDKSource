/*******************************************************************************
	IInteractiveObject

	Creation date: 26/04/2014 02:51
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

interface IInteractiveObject;


/**
 * Activates the interactive object.
 */
simulated function InteractWith(Pawn pawn);

/**
 * This is called when the pawn releases the interaction button.
 */
simulated function Release(Pawn pawn);

/**
 * Gets the message the interactive object displays to the HUD when the player is near.
 */
simulated function string GetMessage();

/**
 * Determines if a pawn is near enough to an interactive object to interact with it.
 */
simulated function bool IsPlayerNear(Pawn pawn);

/**
 * Indicates whether the interactive object requires the player to hold down the use button to continue interacting with it.
 */
simulated function bool MustHold();

/**
 * Gets the length the player must hold down the use button for before the object is activated.
 */
simulated function float GetTriggerDuration();

/**
 * Gets the distance from the object to a specified actor.
 */
simulated function float GetDistanceFrom(Actor actor);