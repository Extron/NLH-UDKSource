/*******************************************************************************
	PawnSensor

	Creation date: 21/04/2013 20:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A pawn sensor is any type of equipment that gives a player information on the location of 
 * other players on the map.  This includes motion sensors and minimaps, thermal/x-ray vision, etc.
 */
class PawnSensor extends Actor
	abstract;

/**
 * Represents a ghost blip.
 */ 
struct Ghost
{
	var vector Location;
	var vector Velocity;
	var float Duration;
	var float Counter;
};


/**
 * A list of ghosts in the sensor.
 */
var Array<Ghost> Ghosts;


simulated function Tick(float dt)
{
	local int i;
	
	for (i = 0;  i < Ghosts.Length; i++)
	{
		Ghosts[i].Location += Ghosts[i].Velocity * dt;
		Ghosts[i].Counter += dt;
		
		if (Ghosts[i].Counter >= Ghosts[i].Duration)
		{
			Ghosts.Remove(i, 1);
			i--;
		}
	}
}

/**
 * Adds a ghost blip to the sensor.
 */
function AddGhost(float duration);
