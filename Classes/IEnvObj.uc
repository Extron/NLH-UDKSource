/*******************************************************************************
	IEnvObj

	Creation date: 10/09/2012 10:22
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

interface IEnvObj;

/**
 * Gets the environment object's list of properties.
 *
 * @returns Returns the object's property list.
 */
simulated function array<string> GetProperties();

/** 
 * Determines if the evnironment object has a specified property.
 *
 * @param property The property to check that the environment object has.
 * @returns Returns true if the object has the specified property, false if not.
 */
simulated function bool HasProperty(string property);

/** 
 * Determines if the evnironment object has all of the specified properties.
 *
 * @param properties The properties to check that the environment object has.
 * @returns Returns true if the object has all of the specified properties, false if not.
 */
simulated function bool HasProperties(array<string> properties);

/**
 * Determines if the object currently has an effect (using its name as a comparer) actively on it.
 * 
 * @param effectName The name of the effect to look for.
 * @returns Returns true if the object has an effect by that name, false if not.
 */
simulated function bool HasEffect(string effectName);

/**
 * Adds an effect to the environment object.
 *
 * @param effect The effect to add to the object.
 */
simulated function AddEffect(EnvironmentEffect effect);

/**
 * Removes an effect from the environment object. 
 *
 * @param effect The effect to remove.
 */
simulated function RemoveEffect(EnvironmentEffect effect);

/**
 * Allows the environment effect to affect a pawn when it is touched by one.
 *
 * @param pawn The pawn that touched to object.
 */
simulated function TouchPawn(ArenaPawn pawn);
