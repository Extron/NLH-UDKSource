/*******************************************************************************
	GFx_MainMenu

	Creation date: 01/04/2013 21:19
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_MainMenu extends GFxMoviePlayer;

const NativeWidth = 1600;
const NativeHeight = 900;

var GFxObject SinglePlayerButton, BotBattleButton, MultiplayerButton, OptionsButton, ExitButton;

var SkeletalMeshComponent Cube;

var ArenaPawn Pawn;

function bool Start(optional bool StartPaused = false)
{
	local SkeletalMeshActor iter;
	local vector v;
	local rotator r;
	
	super.Start(StartPaused);
			
    Advance(0);

	if (ArenaPawn(GetPC().Pawn) != None)
		Pawn = ArenaPawn(GetPC().Pawn);

		
	SinglePlayerButton = GetVariableObject("_root.buttons.single_player_button");
	BotBattleButton = GetVariableObject("_root.buttons.bot_battle_button");
	MultiplayerButton = GetVariableObject("_root.buttons.multiplayer_button");
	ExitButton = GetVariableObject("_root.buttons.exit_button");

	SinglePlayerButton.SetText("Story Mode");
	MultiplayerButton.SetText("Multiplayer");
	BotBattleButton.SetText("Bot Battle");
	ExitButton.SetText("Exit Game");
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			break;
		}
	}	
	
	if (Cube != None)
	{
		if (Cube.GetSocketByName('SinglePlayerSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('SinglePlayerSocket', v, r, 0);
		
			`log(v);
			
			SinglePlayerButton.SetFloat("x", v.x * 2);
			SinglePlayerButton.SetFloat("y", v.y * 2);
			SinglePlayerButton.SetFloat("z", v.z * 2);
		}
		
		if (Cube.GetSocketByName('MultiplayerSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('MultiplayerSocket', v, r, 0);
			
			MultiplayerButton.SetFloat("x", v.x);
			MultiplayerButton.SetFloat("y", v.y);
			MultiplayerButton.SetFloat("z", v.z);
		}
		
		if (Cube.GetSocketByName('BotBattleSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('BotBattleSocket', v, r, 0);
			
			BotBattleButton.SetFloat("x", v.x);
			BotBattleButton.SetFloat("y", v.y);
			BotBattleButton.SetFloat("z", v.z);
		}
		
		if (Cube.GetSocketByName('ExitSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('ExitSocket', v, r, 0);
			
			ExitButton.SetFloat("x", v.x);
			ExitButton.SetFloat("y", v.y);
			ExitButton.SetFloat("z", v.z);
		}
	}
	
	return true;
	
}