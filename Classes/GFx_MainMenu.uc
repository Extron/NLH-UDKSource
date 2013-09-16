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
const ButtonGroupCount = 6;

struct ButtonGroup
{
	var GFxObject Group;
	var array<GFxClikWidget> Buttons;
	var array<string> ButtonNames;
	var name Socket;
	var bool Expanded;
	var bool Over;
};

var ButtonGroup Groups[ButtonGroupCount];

var GFxObject Buttons, BotBattleGroup, SinglePlayerGroup, MultiplayerGroup, CharacterGroup, OptionsGroup, ExitGroup;
var GFxClikWidget SPButton, BBSoloButton, BBCoopButton, MPButton, CEditButton, CNewButton, OButton, EButton;


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
	local GFxClikWidget button;
	local int i, j;
	
	super.Start(StartPaused);
			
    Advance(0);

	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	Buttons = GetVariableObject("_root.buttons");	
	Groups[0].Group = GetVariableObject("_root.buttons.singlePlayerButtons");	
	Groups[1].Group = GetVariableObject("_root.buttons.multiplayerButtons");
	Groups[2].Group = GetVariableObject("_root.buttons.botBattleButtons");	
	Groups[3].Group = GetVariableObject("_root.buttons.characterButtons");
	Groups[4].Group = GetVariableObject("_root.buttons.optionsButtons");	
	Groups[5].Group = GetVariableObject("_root.buttons.exitButtons");

	Groups[0].ButtonNames.AddItem("singlePlayerButton");
	Groups[0].Socket = 'SinglePlayerSocket';
	
	Groups[1].ButtonNames.AddItem("multiplayerButton");
	Groups[1].Socket = 'MultiplayerSocket';
	
	Groups[2].ButtonNames.AddItem("botBattle");
	Groups[2].Socket = 'BotBattleSocket';
	
	Groups[3].ButtonNames.AddItem("character");
	Groups[3].Socket = 'CharacterSocket';
	
	Groups[4].ButtonNames.AddItem("optionsButton");
	Groups[4].Socket = 'OptionsSocket';
	
	Groups[5].ButtonNames.AddItem("exitButton");
	Groups[5].Socket = 'ExitSocket';
	
	for (i = 0; i < ButtonGroupCount; i++)
	{
		for (j = 0; j < Groups[i].ButtonNames.Length; j++)
		{
			button = GFxClikWidget(Groups[i].Group.GetObject(Groups[i].ButtonNames[j], class'GFxClikWidget'));
			
			Groups[i].Buttons.AddItem(button);
			
			if (button == none)
				`warn("Could not find button" @ Groups[i].ButtonNames[j]);
		}
	}
	
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

event bool WidgetInitialized(name widgetName, name widgetPath, GFxObject widget)
{
	local bool handled;
	local int group;
	
	`log("Initializing widget" @ widgetName);
	
	group = FindGroupWithButton(string(widgetName));
	
	if (group > -1)
	{
		Groups[group].Buttons.AddItem(GFxClikWidget(widget));
	}
	
	if (!handled)
	{
		handled = Super.WidgetInitialized(widgetName, widgetPath, widget);    
	}
	
    return handled;
}

function Update(float dt)
{
	Counter += dt;
	
	if (!IsOver() && Rotating)
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
	else if (!IsOver()  && !IsExpanded())
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

function int FindGroupWithButton(string buttonName)
{
	local int i;
	
	for (i = 0; i < ButtonGroupCount; i++)
	{
		if (Groups[i].ButtonNames.Find(buttonName) > -1)
			return i;
	}
	
	return -1;
}

function int FindGroupWithBtnLabel(string label)
{
	local int i, j;
	
	for (i = 0; i < ButtonGroupCount; i++)
	{
		`log("Group buttons" @ Groups[i].Buttons.Length);
		
		for (j = 0; j < Groups[i].Buttons.Length; j++)
		{
			`log("Button" @ Groups[i].Buttons[j]);
			
			if (Groups[i].Buttons[j].GetString("label") == label)
				return i;
		}
	}
	
	return -1;
}

function bool IsOver()
{
	local int i;
	
	for (i = 0; i < ButtonGroupCount; i++)
	{
		if (Groups[i].Over)
			return true;
	}
	
	return false;
}

function bool IsExpanded()
{
	local int i;
	
	for (i = 0; i < ButtonGroupCount; i++)
	{
		if (Groups[i].Expanded)
			return true;
	}
	
	return false;
}
function OnMouseMove(float x, float y, bool mouseDown)
{
	local vector mousePos, d;
	
	mousePos.x = x;
	mousePos.y = y;

	if (mouseDown && !IsExpanded())
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
	local int i;
	
	scale = 1.8;
	
	if (Cube != None)
	{
		for (i = 0; i < ButtonGroupCount; i++)
		{
			if (Cube.GetSocketByName(Groups[i].Socket) != None)
			{
				Cube.GetSocketWorldLocationAndRotation(Groups[i].Socket, v, r, 0);

				if (Groups[i].Expanded)
				{
					Groups[i].Group.SetFloat("width", ExpandedWidth * (1 - v.x / 200));
					Groups[i].Group.SetFloat("height", ExpandedHeight * (1 - v.x / 200));
				}
				else
				{
					Groups[i].Group.SetFloat("width", ButtonWidth * (1 - v.x / 200));
					Groups[i].Group.SetFloat("height", ButtonHeight * (1 - v.x / 200));
				}
				
				v = ProjectPosition(v);
				
				Groups[i].Group.SetFloat("x", v.x * scale);
				Groups[i].Group.SetFloat("y", v.y * scale);
			}
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
	local int group;
	
	group = FindGroupWithBtnLabel(label);
	
	if (group > -1)
	{
		Groups[group].Over = false;
	}
}

function ButtonOver(string label)
{
	local int group;
	local int i;
	
	group = FindGroupWithBtnLabel(label);
	
	if (group > -1)
	{
		Groups[group].Over = true;
		
		for (i = 0; i < ButtonGroupCount; i++)
		{
			if (i != group)
				Groups[i].Over = false;
		}
	}
}

function ButtonClicked(string label)
{
	local int group;
	local int i;
	
	group = FindGroupWithBtnLabel(label);
	
	if (group > -1)
	{
		Groups[group].Expanded = !Groups[group].Expanded;
		
		for (i = 0; i < ButtonGroupCount; i++)
		{
			if (i != group)
				Groups[i].Expanded = false;
		}
	}
	
	if (label == "Exit")
	{
		ConsoleCommand("exit");
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