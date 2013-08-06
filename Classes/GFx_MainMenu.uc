/*******************************************************************************
	GFx_MainMenu

	Creation date: 01/04/2013 21:19
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_MainMenu extends GFx_Menu;


const NativeWidth = 1600;
const NativeHeight = 900;
const ButtonWidth = 256;
const ButtonHeight = 48;
const ExpandedWidth = 512;
const ExpandedHeight = 240;
const AspectRatio = 1.777777778;
const Far = 100;
const Near = 1;

var GFxObject Buttons, BotBattleGroup, SinglePlayerGroup, MultiplayerGroup, OptionsGroup, ExitGroup;
var GFxClikWidget SPButton, BBSoloButton, BBCoopButton, MPButton, OButton, EButton;


/**
 * The Duk cube that is used as a display prop for the menu.
 */
var SkeletalMeshComponent Cube;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * Various rotation variables to help rotate the Dek cube.
 */
var rotator OrigRot;

/**
 * The previous mouse position.
 */
var vector OldMousePos;

/**
 * The counter for rotations and timers on the nemu.
 */
var float Counter;

/**
 * The currently active timer.  A -1 indicates no active timer.
 */
var float Timer;

/**
 * The duration of the current random rotation.
 */
var float RotationDuration;

/**
 * The button that is currently being hovered on.  Will be empty if no button is.
 */
var string CurrentOverButton;

/**
 * Indicates whether or not certain buttons are expanded or not.
 */
var bool SPExpanded, MPExpanded, BBExpanded, OExpanded;

/**
 * Indicates that the menu tick will ignore button states.
 */
var bool IgnoreButtons;

/**
 * Indicates that the menu is playing the closing animation.
 */
var bool Closing;

var bool Rotating;

/**
 * The delegate to call when the menu closes.
 */
delegate OnClose();


function bool Start(optional bool StartPaused = false)
{
	local SkeletalMeshActor iter;
	local AN_BlendByState node;
	
	super.Start(StartPaused);
			
    Advance(0);

	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
		
	Buttons = GetVariableObject("_root.buttons");	
	SinglePlayerGroup = GetVariableObject("_root.buttons.singlePlayerButtons");	
	MultiplayerGroup = GetVariableObject("_root.buttons.multiplayerButtons");
	BotBattleGroup = GetVariableObject("_root.buttons.botBattleButtons");	
	OptionsGroup = GetVariableObject("_root.buttons.optionsButtons");	
	ExitGroup = GetVariableObject("_root.buttons.exitButtons");

	SPButton = GFxClikWidget(SinglePlayerGroup.GetObject("singlePlayerButton", class'GFxClikWidget'));
	BBSoloButton = GFxClikWidget(BotBattleGroup.GetObject("singlePlayer", class'GFxClikWidget'));
	BBCoopButton = GFxClikWidget(BotBattleGroup.GetObject("multiplayer", class'GFxClikWidget'));
	MPButton = GFxClikWidget(MultiplayerGroup.GetObject("multiplayerButton", class'GFxClikWidget'));
	OButton = GFxClikWidget(OptionsGroup.GetObject("optionsButton", class'GFxClikWidget'));
	EButton = GFxClikWidget(ExitGroup.GetObject("exitButton", class'GFxClikWidget'));
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			break;
		}
	}	
	
	Cube.Owner.SetPhysics(PHYS_Rotating);

	foreach Cube.AllAnimNodes(class'AN_BlendByState', node)
		node.SetState("MainMenu");
	
	PositionButtons();

	return true;
	
}

function Update(float dt)
{
	Counter += dt;
	
	if (CurrentOverButton == "" && Rotating)
	{
		if (Abs(Cube.Owner.RotationRate.Pitch) < 4 && Abs(Cube.Owner.RotationRate.Yaw) < 4 && Abs(Cube.Owner.RotationRate.Roll) < 4)
		{
			Rotating = false;
		}
		
		Cube.Owner.RotationRate.Pitch *= 0.95;
		Cube.Owner.RotationRate.Yaw *= 0.95;
		Cube.Owner.RotationRate.Roll *= 0.95;
		
		PositionButtons();
		
	}
	else if (CurrentOverButton == "" && !(SPExpanded || MPExpanded || BBExpanded || OExpanded) && !Rotating)
	{
		Cube.Owner.RotationRate.Pitch += 64 * Cos(Counter);
		Cube.Owner.RotationRate.Yaw += 64 * Cos(2.5 * Counter);
		Cube.Owner.RotationRate.Roll += 64 * Cos(0.75 * Counter);

		PositionButtons();
	}
	else if (Closing)
	{
		Cube.Owner.SetRotation(RLerp(OrigRot, rot(0, -16384, 0), Counter / RotationDuration, true));
	}
	else
	{
		Cube.Owner.RotationRate.Pitch = 0;
		Cube.Owner.RotationRate.Yaw = 0;
		Cube.Owner.RotationRate.Roll = 0;
	}
}

function OnMouseMove(float x, float y, bool mouseDown)
{
	local vector mousePos, d;
	
	mousePos.x = x;
	mousePos.y = y;

	if (mouseDown && !(SPExpanded || MPExpanded || BBExpanded || OExpanded))
	{
		d = mousePos - OldMousePos;
		
		if (VSize(d) > 5)
		{
			Rotating = true;
			
			Cube.Owner.RotationRate.Pitch = 0;
			Cube.Owner.RotationRate.Yaw = -d.x * 1024;
			Cube.Owner.RotationRate.Roll = d.y * 1024;
		}
	}
	
	OldMousePos = mousePos;
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function CloseAnimCompleted()
{
	OnClose();
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

			if (SPExpanded)
			{
				SinglePlayerGroup.SetFloat("width", ExpandedWidth * (1 - v.x / 200));
				SinglePlayerGroup.SetFloat("height", ExpandedHeight * (1 - v.x / 200));
			}
			else
			{
				SinglePlayerGroup.SetFloat("width", ButtonWidth * (1 - v.x / 200));
				SinglePlayerGroup.SetFloat("height", ButtonHeight * (1 - v.x / 200));
			}
			
			v = ProjectPosition(v);
			
			SinglePlayerGroup.SetFloat("x", v.x * scale);
			SinglePlayerGroup.SetFloat("y", v.y * scale);
		}
		
		if (Cube.GetSocketByName('MultiplayerSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('MultiplayerSocket', v, r, 0);
			
			if (MPExpanded)
			{
				MultiplayerGroup.SetFloat("width", ExpandedWidth * (1 - v.x / 200));
				MultiplayerGroup.SetFloat("height", ExpandedHeight * (1 - v.x / 200));
			}
			else
			{
				MultiplayerGroup.SetFloat("width", ButtonWidth * (1 - v.x / 200));
				MultiplayerGroup.SetFloat("height", ButtonHeight * (1 - v.x / 200));
			}
			
			v = ProjectPosition(v);
			
			MultiplayerGroup.SetFloat("x", v.x * scale);
			MultiplayerGroup.SetFloat("y", v.y * scale);
		}
		
		if (Cube.GetSocketByName('BotBattleSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('BotBattleSocket', v, r, 0);
			
			if (BBExpanded)
			{
				BotBattleGroup.SetFloat("width", ExpandedWidth * (1 - v.x / 200));
				BotBattleGroup.SetFloat("height", ExpandedHeight * (1 - v.x / 200));
			}
			else
			{
				BotBattleGroup.SetFloat("width", ButtonWidth * (1 - v.x / 200));
				BotBattleGroup.SetFloat("height", ButtonHeight * (1 - v.x / 200));
			}
			
			v = ProjectPosition(v);
			
			BotBattleGroup.SetFloat("x", v.x * scale);
			BotBattleGroup.SetFloat("y", v.y * scale);
		}
		
		if (Cube.GetSocketByName('OptionsSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('OptionsSocket', v, r, 0);
			
			if (OExpanded)
			{
				OptionsGroup.SetFloat("width", ExpandedWidth * (1 - v.x / 200));
				OptionsGroup.SetFloat("height", ExpandedHeight * (1 - v.x / 200));
			}
			else
			{
				OptionsGroup.SetFloat("width", ButtonWidth * (1 - v.x / 200));
				OptionsGroup.SetFloat("height", ButtonHeight * (1 - v.x / 200));
			}
			
			v = ProjectPosition(v);
			
			OptionsGroup.SetFloat("x", v.x * scale);
			OptionsGroup.SetFloat("y", v.y * scale);
		}
		
		if (Cube.GetSocketByName('ExitSocket') != None)
		{
			Cube.GetSocketWorldLocationAndRotation('ExitSocket', v, r, 0);
			
			ExitGroup.SetFloat("width", ButtonWidth * (1 - v.x / 200));
			ExitGroup.SetFloat("height", ButtonHeight * (1 - v.x / 200));
			
			v = ProjectPosition(v);
			
			ExitGroup.SetFloat("x", v.x * scale);
			ExitGroup.SetFloat("y", v.y * scale);
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
	if (CurrentOverButton == label)
	{
		CurrentOverButton = "";
	}
}

function ButtonOver(string label)
{
	CurrentOverButton = label;
}

function ButtonClicked(string label)
{
	if (label == "Exit")
	{
		ConsoleCommand("exit");
	}
	else if (label == "Options")
	{
		OExpanded = !OExpanded;
		SPExpanded = false;
		MPExpanded = false;
		BBExpanded = false;
	}
	else if (label == "Campaign")
	{
		SPExpanded = !SPExpanded;
		OExpanded = false;
		MPExpanded = false;
		BBExpanded = false;
	}
	else if (label == "Muliplayer")
	{
		MPExpanded = !MPExpanded;
		SPExpanded = false;
		OExpanded = false;
		BBExpanded = false;
	}
	else if (label == "Bot Battle")
	{
		BBExpanded = !BBExpanded;
		SPExpanded = false;
		MPExpanded = false;
		OExpanded = false;
	}
	else if (label == "Solo")
	{
		OnSoloBotBattleClicked();
	}
	else if (label == "Controls")
	{
		OnControlsClicked();
	}
}

function OnSoloBotBattleClicked()
{
	Closing = true;
	IgnoreButtons = true;
	
	Cube.Owner.RotationRate = rot(0, 0, 0);
	Cube.Owner.SetPhysics(PHYS_None);
	OrigRot = Cube.Owner.Rotation;
	Counter = 0;
	RotationDuration = 0.35;
	
	OnClose = GotoSoloBotBattle;
	
	CloseMenu();
}

function OnControlsClicked()
{
	Closing = true;
	IgnoreButtons = true;
	
	Cube.Owner.RotationRate = rot(0, 0, 0);
	Cube.Owner.SetPhysics(PHYS_None);
	OrigRot = Cube.Owner.Rotation;
	Counter = 0;
	RotationDuration = 0.35;
	
	OnClose = GotoControlsBattle;
	
	CloseMenu();
}

function GotoSoloBotBattle()
{
	local GFx_SoloBotBattle menu;
	
	menu = new class'Arena.GFx_SoloBotBattle';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);

	Cube.Owner.SetRotation(rot(0, -16384, 0));

	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);

	Close();
}

function GotoControlsBattle()
{
	local GFx_Controls menu;
	
	menu = new class'Arena.GFx_Controls';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);

	Cube.Owner.SetRotation(rot(0, -16384, 0));

	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);

	Close();
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.MainMenu'
	
	RotationDuration=10
	Timer=-1
	
	bCaptureInput=true
}