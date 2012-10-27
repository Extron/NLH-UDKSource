/*******************************************************************************
	GI_TeamCountdown

	Creation date: 17/09/2012 10:42
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GI_TeamCountdown extends ArenaGameInfo;

/** An array containing the amount of time remaining for each team. */
var array<float> TimeRemaining;

/** The maximum allowed respawn time that a player must have. */
var float MaxRespawnTime;

/** 
 * Allows the game info to update per update cycle.
 *
 * @param dt - The amount of time since the last update.
 */
function Tick(float dt)
{
	local int i;
	
	for (i = 0; i < Teams.Length; i++)
	{
		if (TeamDown(i))
		{
			TI_Countdown(Teams[i]).CountDown(dt);
			
			if (TI_Countdown(Teams[i]).TimeComplete() && Teams.Length == 2)
				EndGame(Teams[1 - i].GetTeamMembers()[0].PlayerReplicationInfo, "CountdownEnded");
		}
	}
}

/**
 * Returns whether all members of a team are currently dead. 
 *
 * @param team - The index of the team to check.
 * @returns Returns true if all team members are dead, false otherwise.
 */
function bool TeamDown(int team)
{
	local array<ArenaPlayerController> players;
	local int i;
	
	if (Teams.Length > team)
	{
		players = TI_Countdown(Teams[team]).GetTeamMembers();
		
		for (i = 0; i < players.Length; i++)
		{
			if (!players[i].bFrozen)
			{
				return false;
			}
		}
		
		return true;
	}
	
	return false;
}

defaultproperties
{
	//GameName="Team Countdown"
	TeamInfoClass=class'Arena.TI_Countdown'
	MaxTeams=2
}