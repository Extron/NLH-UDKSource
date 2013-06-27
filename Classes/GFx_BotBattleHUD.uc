/*******************************************************************************
	GFx_BotBattleHUD

	Creation date: 12/05/2013 23:27
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_BotBattleHUD extends GFx_BasicHUD;

function UpdateHUD(float dt)
{
	local ArenaPawn pawn;
	local GRI_BotBattle gri;
	local PRI_BotBattle pri;
	local string leftMsg;
	
	super.UpdateHUD(dt);
	
	if (Hidden)
		return;
		
	if (ArenaPawn(GetPC().Pawn) != None)
		pawn = ArenaPawn(GetPC().Pawn);
		
	leftMsg = "";
	
	if (pawn != None && pawn.Health > 0)
	{
		pri = PRI_BotBattle(pawn.PlayerReplicationInfo);
		gri = GRI_BotBattle(pawn.WorldInfo.GRI);
		
		if (pri != None)
		{
			leftMsg $= "Score:" @ pri.Score $ "\n\n";
			leftMsg $= "Tokens:" @ pri.Tokens $ "\n\n";
		}
		
		if (gri != None)
		{
			leftMsg $= "Wave:" @ gri.CurrentWave $ "\n";
		}
	}
	
	LeftMessageBox.SetMessage(leftMsg);
}