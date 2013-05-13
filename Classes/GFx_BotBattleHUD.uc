/*******************************************************************************
	GFx_BotBattleHUD

	Creation date: 12/05/2013 23:27
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_BotBattleHUD extends GFx_BasicHUD;


var GFxObject ScoreModule, Score, Wave, Time;

function Init(optional LocalPlayer player)
{	
	super.Init(player);
	
	ScoreModule = GetVariableObject("_root.score_module");
	Score = GetVariableObject("_root.score_module.score.label");
	Wave = GetVariableObject("_root.score_module.wave.label");
	Time = GetVariableObject("_root.score_module.time.label");
	
	AngleComponent(ScoreModule);
}

function UpdateHUD(float dt)
{
	local ArenaPawn pawn;
	local GRI_BotBattle gri;
	local ArenaPRI pri;
	
	super.UpdateHUD(dt);
	
	if (Hidden)
		return;
		
	if (ArenaPawn(GetPC().Pawn) != None)
		pawn = ArenaPawn(GetPC().Pawn);
		
	if (pawn != None && pawn.Health > 0)
	{
		pri = ArenaPRI(pawn.PlayerReplicationInfo);
		gri = GRI_BotBattle(pawn.WorldInfo.GRI);
		
		if (pri != None)
		{
			Score.SetText("Score:" @ pri.Score);	
		}
		
		if (gri != None)
		{
			Wave.SetText("Wave:" @ gri.CurrentWave);
		}
		
		Time.SetText("");
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.BotBattleHUD'
}