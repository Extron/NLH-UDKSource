/*******************************************************************************
	ArenaPRI

	Creation date: 02/02/2013 17:23
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPRI extends PlayerReplicationInfo;

/**
 * Overridden to prevent bots from broadcasting messages.
 */
simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	if (bBot)
		return false;
	else
		return Super.ShouldBroadcastWelcomeMessage(bExiting);
}