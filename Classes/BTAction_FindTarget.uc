/*******************************************************************************
	BTAction_FindTarget

	Creation date: 22/08/2013 13:16
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Attempts to find the nearest valid enemy target to attack.
 */
class BTAction_FindTarget extends BTAction;


state Running
{
	simulated function BeginState(name prev)
	{
		local ArenaPawn p;
		local ArenaPawn nearest;
		
		OnRunning(self);
		
		nearest = None;
		
		if (Controller.PlayerReplicationInfo == None || Controller.PlayerReplicationInfo.Team == None)
		{
			GotoState('Failed');
			return;
		}
		
		foreach WorldInfo.AllPawns(class'ArenaPawn', p)
		{
			if (p != Controller.Pawn && !p.Invisible && Controller.CanSee(p))
			{			
				if (p.PlayerReplicationInfo != None && p.PlayerReplicationInfo.Team != None)
				{
					if (p.PlayerReplicationInfo.Team.TeamIndex != Controller.PlayerReplicationInfo.Team.TeamIndex)
					{						
						if (nearest != None)
						{
							if (VSize(Controller.Pawn.Location - p.Location) < VSize(Controller.Pawn.Location - nearest.Location))
								nearest = p;
						}
						else
						{
							nearest = p;
						}
					}
				}
			}
		}
		
		if (nearest == None)
		{
			GotoState('Failed');
			return;
		}
		else
		{
			Controller.Focus = nearest;
			GotoState('Succeeded');
			return;
		}
	}
}