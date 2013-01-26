/*******************************************************************************
	ArenaTeamInfo

	Creation date: 18/09/2012 12:35
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaTeamInfo extends TeamInfo;


/**
 * Gets all the player controllers that are on the team. 
 *
 * @returns Returns the list of player controllers on the team.
 */
function array<ArenaPlayerController> GetTeamMembers()
{
	local array<ArenaPlayerController> players;
	local ArenaPlayerController player;
	
	foreach DynamicActors(class'ArenaPlayerController', player)
	{
		if (player.PlayerReplicationInfo != None && player.PlayerReplicationInfo.Team != None)
		{
			if (player.PlayerReplicationInfo.Team == self)
				players.AddItem(player);
		}
	}
	
	return players;
}

event TeamMemberKilled(Controller member)
{
}