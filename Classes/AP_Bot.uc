/*******************************************************************************
	AP_Bot

	Creation date: 02/03/2013 22:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A base pawn that is used exclusively for AI controlled bots.
 */
class AP_Bot extends ArenaPawn
	abstract;
	
/**
 * Allows the pawn to govern when to shoot.
 */
simulated function bool CanShoot();

auto state Idle
{
}

state MoveToTarget
{
}

state Focusing
{
}

state Stunned
{
}

state Recovering
{
}

state Wandering
{
}
