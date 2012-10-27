/*******************************************************************************
	TI_Countdown

	Creation date: 18/09/2012 12:45
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class TI_Countdown extends ArenaTeamInfo;


/** The amount of time remaining for the team, in seconds. */
var float TimeRemaining;


/**
 * Gets whether the team has any time left.
 *
 * @returns Returns true if the team is out of time, false if not.
 */
function bool TimeComplete()
{
	return TimeRemaining <= 0;
}

/**
 * Reduces the team's timer.
 *
 * @param dt - The time since the last update.
 */
function CountDown(float dt)
{
	TimeRemaining -= dt;
}

defaultproperties
{
	TimeRemaining=60
}