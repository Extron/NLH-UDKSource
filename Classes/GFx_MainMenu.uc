/*******************************************************************************
	GFx_MainMenu

	Creation date: 01/04/2013 21:19
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_MainMenu extends GFx_Menu;

const NativeWidth = 1600;
const NativeHeight = 900;
const AspectRatio = 1.777777778;
const Far = 100;
const Near = 1;

var GFxObject Buttons, SPBW, BBBW, MPBW, OBW, EBW;
var GFxClikWidget SPButton, BBButton, MPButton, OButton, EButton;

var SkeletalMeshComponent Cube;

var AP_Specter Pawn;

var rotator RandRot;

var rotator OrigRot;

var rotator DesiredRot;

var float Counter;

/**
 * The button that is currently being hovered on.  Will be empty if no button is.
 */
var string CurrentOverButton;

function bool Start(optional bool StartPaused = false)
{
	local vector btnPos;
	
	local SkeletalMeshActor iter;
	
	super.Start(StartPaused);
			
    Advance(0);

	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
		
	Buttons = GetVariableObject("_root.buttons");
	
	SPBW = GetVariableObject("_root.buttons.single_player_button");
	BBBW = GetVariableObject("_root.buttons.bot_battle_button");
	MPBW = GetVariableObject("_root.buttons.multiplayer_button");
	OBW = GetVariableObject("_root.buttons.options_button");
	EBW = GetVariableObject("_root.buttons.exit_button");

	SPButton = GFxClikWidget(SPBW.GetObject("button", class'GFxClikWidget'));
	BBButton = GFxClikWidget(BBBW.GetObject("button", class'GFxClikWidget'));
	MPButton = GFxClikWidget(MPBW.GetObject("button", class'GFxClikWidget'));
	OButton = GFxClikWidget(OBW.GetObject("button", class'GFxClikWidget'));
	EButton = GFxClikWidget(EBW.GetObject("button", class'GFxClikWidget'));
	
	SPButton.SetString("label", "Campaign");
	MPButton.SetString("label", "Multiplayer");
	BBButton.SetString("label", "Bot Battle");
	OButton.SetString("label", "Options");
	EButton.SetString("label", "Exit");
	
	SPButton.GotoAndPlay("up");
	MPButton.GotoAndPlay("up");
	BBButton.GotoAndPlay("up");
	OButton.GotoAndPlay("up");
	EButton.GotoAndPlay("up");
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			btnPos = ProjectPosition(iter.Location);
			btnPos.x += NativeWidth * 0.5;
			btnPos.y -= NativeHeight * 0.5;
			
			`log("CubePos" @ iter.Location @ "BtnPos" @ btnPos);
			break;
		}
	}	
	
	Buttons.SetFloat("x", btnPos.x);
	Buttons.SetFloat("y", -btnPos.y - 64);
	

	PositionButtons();
	
	RandRot.Yaw = Rand(65536);
	RandRot.Pitch = Rand(65536);
	RandRot.Roll = Rand(65536);
	OrigRot = Cube.GetRotation();
		
	return true;
	
}

function Update(float dt)
{
	if (CurrentOverButton == "")
	{
		if (Counter > 10.0)
		{
			Counter = 0.0;
			OrigRot = RandRot;
			RandRot.Yaw = Rand(65536);
			RandRot.Pitch = Rand(65536);
			RandRot.Roll = Rand(65536);
		}

		Counter += dt;
		
		Cube.SetRotation(RLerp(OrigRot, RandRot, Counter / 10, true));
		
		PositionButtons();
	}
	/*
	else
	{
		if (Counter > 1.0)
		{
			OrigRot = DesiredRot;
		}

		Counter += dt;
		
		Cube.SetRotation(RLerp(OrigRot, DesiredRot, Counter, true));
		
		PositionButtons();
	}*/
}

function PositionButtons()
{
	local vector v;
	local rotator r;
	local float scale;
	
	scale = 1.8;
	
	if (Cube != None)
	{
		if (Cube.GetSocketByName('SinglePlayerSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('SinglePlayerSocket', v, r, 0);

			v = ProjectPosition(v);
			
			SPBW.SetFloat("x", v.x * scale);
			SPBW.SetFloat("y", v.y * scale);
			//SPBW.SetFloat("z", v.x * 4);
		}
		
		if (Cube.GetSocketByName('MultiplayerSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('MultiplayerSocket', v, r, 0);
			
			v = ProjectPosition(v);
			
			MPBW.SetFloat("x", v.x * scale);
			MPBW.SetFloat("y", v.y * scale);
			//MPBW.SetFloat("z", v.x * 4);
		}
		
		if (Cube.GetSocketByName('BotBattleSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('BotBattleSocket', v, r, 0);
			
			v = ProjectPosition(v);
			
			BBBW.SetFloat("x", v.x * scale);
			BBBW.SetFloat("y", v.y * scale);
			//BBBW.SetFloat("z", v.x * 4);
		}
		
		if (Cube.GetSocketByName('OptionsSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('OptionsSocket', v, r, 0);
			
			v = ProjectPosition(v);
			
			OBW.SetFloat("x", v.x * scale);
			OBW.SetFloat("y", v.y * scale);
			//EBW.SetFloat("z", v.x * 4);
		}
		
		if (Cube.GetSocketByName('ExitSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('ExitSocket', v, r, 0);
			
			v = ProjectPosition(v);
			
			EBW.SetFloat("x", v.x * scale);
			EBW.SetFloat("y", v.y * scale);
			//EBW.SetFloat("z", v.x * 4);
		}
	}
}

function vector ProjectPosition(vector pos)
{
	local vector viewPos;
	local vector newPos;
	local vector cameraPos;
	local rotator cameraRot;
	local float theta;
	
	GetPC().GetPlayerViewPoint(cameraPos, cameraRot);
	theta = GetPC().PlayerCamera.DefaultFOV * PI / 180;
	
	viewPos = pos - cameraPos;
	
	newPos.x = viewPos.y / (AspectRatio * viewPos.x * Tan(theta / 2)) * NativeWidth * 0.5;
	newPos.y = -viewPos.z / (viewPos.x * Tan(theta / 2)) * NativeHeight * 0.5;
	newPos.z = (Far + Near + 2 * Far * Near / viewPos.x ) / (Far - Near);
	
	return newPos;
}

function ButtonUp(string label)
{
	`log("Button" @ label @ "is up.");
	
	if (CurrentOverButton == label)
	{
		CurrentOverButton = "";
		//OrigRot = RLerp(OrigRot, DesiredRot, Counter, true);
		//Counter = 0.0;
	}
}

function ButtonOver(string label)
{
	`log("Button" @ label @ "is hovered.");
	CurrentOverButton = label;
	
	if (label == "Campaign")
	{
		DesiredRot = rot(8192, 24576, 0);
	}
	else
	{
		DesiredRot = RLerp(OrigRot, RandRot, Counter, true);
	}
	
	//OrigRot = RLerp(OrigRot, RandRot, Counter, true);
	//Counter = 0.0;
}

function ButtonClicked(string label)
{
	if (label == "Exit")
		ConsoleCommand("exit");
}