/*******************************************************************************
	GFx_Controls

	Creation date: 29/06/2013 01:05
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_Controls extends GFx_Menu;

const NativeWidth = 1600;
const NativeHeight = 900;


/**
 * The list of commands that will be displayed in list one.
 */
var array<string> ListOneCommands;

/**
 * The list of commands that will be displayed in list one.
 */
var array<string> ListTwoCommands;

var array<KeyBind> ListOneBindings;

var array<KeyBind> ListTwoBindings;

/**
 * The Dek cube to use to help display the menu.
 */
var SkeletalMeshComponent Cube;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The menu container for the weapon stats.
 */
var GFxObject Cursor;

/**
 * When closing, this is the destination menu.
 */
var string Destination;

/**
 * The delegate to call when the menu closes.
 */
delegate OnClose();


function bool Start(optional bool StartPaused = false)
{
	local SkeletalMeshActor iter;
	
	super.Start(StartPaused);
	Advance(0);

	Cursor = GetVariableObject("_root.cursor");
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			break;
		}
	}
		
	BuildBindingList();
	
	return true;
}

function Update(float dt)
{
}

function PostRender()
{
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function FillListOne(array<GFxObject> list)
{
	ActionScriptVoid("_root.FillListOne");
}

function FillListTwo(array<GFxObject> list)
{
	ActionScriptVoid("_root.FillListTwo");
}

function KeyBindingChanged(int bindingIndex, int list, string key, bool shift, bool ctrl, bool alt)
{
	local GFxObject displayItem;
	local string binding;

	displayItem = CreateObject("Object");
	
	binding = key;
			
	ClearIdenticalBinding(GetBindingName(key));
	
	if (list == 1)
	{
		displayItem.SetString("command", GetCommandDisplay(ListOneBindings[bindingIndex].Command));
		displayItem.SetString("binding", binding);
		
		ListOneBindings[bindingIndex].Name = GetBindingName(key);
		ListOneBindings[bindingIndex].Shift = shift;
		ListOneBindings[bindingIndex].Control = ctrl;
		ListOneBindings[bindingIndex].Alt = alt;
		
		`log("Binding" @ key @ GetBindingName(key));
	}
	else
	{
		displayItem.SetString("command", GetCommandDisplay(ListTwoBindings[bindingIndex].Command));
		displayItem.SetString("binding", binding);
		
		ListTwoBindings[bindingIndex].Name = GetBindingName(key);
		ListTwoBindings[bindingIndex].Shift = shift;
		ListTwoBindings[bindingIndex].Control = ctrl;
		ListTwoBindings[bindingIndex].Alt = alt;
		
		`log("Binding" @ key @ GetBindingName(key));
	}
	
	DisplayListTwo();
	DisplayListOne();
}

function ClearIdenticalBinding(name binding)
{
	local int i;
	
	for (i = 0; i < ListOneBindings.Length; i++)
	{
		if (binding == ListOneBindings[i].Name)
		{
			`log("List one command" @ ListOneBindings[i].Command @ "has identical binding");
			ListOneBindings[i].Name = '';
		}
	}
	
	for (i = 0; i < ListTwoBindings.Length; i++)
	{
		if (binding == ListTwoBindings[i].Name)
		{
			`log("List two command" @ ListTwoBindings[i].Command @ "has identical binding");
			ListTwoBindings[i].Name = '';
		}
	}
}

function BuildBindingList()
{
	local int i;
	
	for (i = 0; i < PlayerController(Pawn.Controller).PlayerInput.Bindings.Length; i++)
	{
		if (InStr(string(PlayerController(Pawn.Controller).PlayerInput.Bindings[i].Name), "Xbox") > -1)
			continue;

		`log("Player bindings" @ PlayerController(Pawn.Controller).PlayerInput.Bindings[i].Command);
		
		if (ListOneCommands.Find(PlayerController(Pawn.Controller).PlayerInput.Bindings[i].Command) > -1)
			ListOneBindings.AddItem(PlayerController(Pawn.Controller).PlayerInput.Bindings[i]);
		else if (ListTwoCommands.Find(PlayerController(Pawn.Controller).PlayerInput.Bindings[i].Command) > -1)
			ListTwoBindings.AddItem(PlayerController(Pawn.Controller).PlayerInput.Bindings[i]);
	}
	
	DisplayListOne();
	DisplayListTwo();
}

function DisplayListOne()
{
	local array<GFxObject> listOneDisplay;
	local GFxObject displayItem;
	local string command, binding;
	local int i;
	
	for (i = 0; i < ListOneBindings.Length; i++)
	{
		binding = string(ListOneBindings[i].Name);
		command = ListOneBindings[i].Command;
		
		displayItem = CreateObject("Object");
		binding = GetBindingDisplay(binding);
		
		if (ListOneBindings[i].Shift)
			binding = "Shift+" $ binding;
			
		displayItem.SetString("command", GetCommandDisplay(command));
		displayItem.SetString("binding", binding);

		listOneDisplay.AddItem(displayItem);
	}
	
	FillListOne(listOneDisplay);
}

function DisplayListTwo()
{
	local array<GFxObject> listTwoDisplay;
	local GFxObject displayItem;
	local string command, binding;
	local int i;
	
	for (i = 0; i < ListTwoBindings.Length; i++)
	{
		binding = string(ListTwoBindings[i].Name);
		command = ListTwoBindings[i].Command;
		
		displayItem = CreateObject("Object");
		binding = GetBindingDisplay(binding);
		
		if (ListTwoBindings[i].Shift)
			binding = "Shift+" $ binding;
			
		displayItem.SetString("command", GetCommandDisplay(command));
		displayItem.SetString("binding", binding);

		listTwoDisplay.AddItem(displayItem);
	}
	
	FillListTwo(listTwoDisplay);
}
function PlayOpenAnimation()
{
	local AN_BlendByState node;
	
	foreach Cube.AllAnimNodes(class'AN_BlendByState', node)
		node.SetState("Controls");
		
	PlayCubeAnimation('ToControlsAnimation');

	ArenaPlayerController(Pawn.Controller).SetFOVWithTime(55, 0.6);
}

function PlayCloseAnimation()
{
	local AN_BlendByState node;
	
	if (Destination == "Main Menu")
	{		
		foreach Cube.AllAnimNodes(class'AN_BlendByState', node)
			node.SetState("MainMenu");
			
		PlayCubeAnimation('FromControlsAnimation');
		
		ArenaPlayerController(Pawn.Controller).SetFOVWithTime(90, 0.6);
	}
}

function CloseAnimCompleted()
{
	OnClose();
}

function OpenAnimCompleted()
{
}

simulated function PlayCubeAnimation(name sequence)
{
	local AnimNodePlayCustomAnim node;

	node = AnimNodePlayCustomAnim(AnimTree(Cube.Animations).Children[0].Anim);

	node.PlayCustomAnim(sequence, 1.0, , , false);
}

function ButtonClicked(string label)
{
	`log("Button clicked" @ label);
	
	if (label == "Cancel")
	{
		OnBackButtonClicked();
	}
	else if (label == "Save")
	{
		SaveBindings();
		OnBackButtonClicked();
	}
}

function OnBackButtonClicked()
{
	OnClose = GotoMainMenu;
	Destination = "Main Menu";
	
	PlayCloseAnimation();
	CloseMenu();
}

function GotoMainMenu()
{
	local GFx_MainMenu menu;
	
	menu = new class'Arena.GFx_MainMenu';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);

	Cube.Owner.SetRotation(rot(0, -16384, 0));
	Cube.Owner.SetPhysics(PHYS_Rotating);
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);
	
	Close();
}

function SaveBindings()
{
	local int i, j;
	local PlayerInput playerInput;
	
	playerInput = PlayerController(Pawn.Controller).PlayerInput;
	
	for (j = 0; j < playerInput.Bindings.Length; j++)
	{
		for (i = 0; i < ListOneBindings.Length; i++)
		{
			if (playerInput.Bindings[j].Command == ListOneBindings[i].Command)
				playerInput.Bindings[j] = ListOneBindings[i];
		}
		
		for (i = 0; i < ListTwoBindings.Length; i++)
		{
			if (playerInput.Bindings[j].Command == ListTwoBindings[i].Command)
				playerInput.Bindings[j] = ListTwoBindings[i];
		}
	}
	
	playerInput.SaveConfig();
}

/**
 * Converts a config command to a displayable string.
 */
function string GetCommandDisplay(string command)
{
	switch (command)
	{
	case "GBA_MoveForward":
		return "Forward";
		
	case "GBA_Backward":
		return "Backward";
	
	case "GBA_StrafeLeft":
		return "Strafe Left";
		
	case "GBA_StrafeRight":
		return "Strafe Right";
		
	case "GBA_Use":
		return "Use";
		
	case "GBA_Sprint":
		return "Sprint";
				
	case "GBA_Duck":
		return "Crouch";
		
	case "GBA_Use":
		return "Interact/Use";
		
	case "GBA_Fire":
		return "Fire Weapon";
				
	case "GBA_FireAbility":
		return "Fire Ability";
				
	case "GBA_ADS":
		return "Aim Down Sights";
				
	case "GBA_Reload":
		return "Reload";
				
	case "GBA_Melee":
		return "Melee";
		
	case "GBA_PrevWeapon":
		return "Previous Weapon";
				
	case "GBA_NextWeapon":
		return "Next Weapon";
				
	case "GBA_PrevAbility":
		return "Previous Ability";
				
	case "GBA_NextAbility":
		return "Next Ability";
				
	case "GBA_ToggleSide":
		return "Toggle Side Attachment";
				
	case "GBA_ToggleUnder":
		return "Toggle Under Attachment";
				
	case "GBA_ToggleOptics":
		return "Toggle Optics";
				
	case "GBA_ToggleBarrel":
		return "Toggle Barrel";
				
	case "GBA_ToggleMuzzle":
		return "Toggle Muzzle";
				
	case "GBA_ToggleStock":
		return "Toggle Stock";
		
	default:
		return command;
	}
}

function string GetBindingDisplay(string binding)
{
	switch (binding)
	{
	case "Comma":
		return ",";
		
	case "SpaceBar":
		return "Space";
		
	case "Period":
		return ".";
		
	case "SemiColon":
		return ";";
		
	case "LeftMouseButton":
		return "Left Click";
		
	case "RightMouseButton":
		return "Right Click";
		
	case "MouseScrollUp":
		return "Scroll Up";
		
	case "MouseScrollDown":
		return "Scroll Down";
		
	case "LeftShift":
		return "Left Shift";
		
	case "RightShift":
		return "Right Shift";
		
	case "LeftControl":
		return "Left Ctrl";
		
	case "RightControl":
		return "Right Ctrl";
	
	case "LeftAlt":
		return "Left Alt";
		
	case "RightAlt":
		return "Right Alt";
		
	case "one":
		return "1";
		
	case "two":
		return "2";
		
	case "three":
		return "3";
		
	case "four":
		return "4";
		
	case "five":
		return "5";
		
	case "six":
		return "6";
		
	case "seven":
		return "7";
		
	case "eight":
		return "8";
		
	case "nine":
		return "9";
		
	case "zero":
		return "0";
		
	default:
		return binding;
	}
}

function name GetBindingName(string binding)
{
	switch (binding)
	{
	case ",":
		return name("Comma");
		
	case " ":
		return name("SpaceBar");
		
	case ".":
		return name("Period");
		
	case ";":
		return name("SemiColon");
		
	case "LeftShift":
		return name("LeftShift");
		
	case "LeftCtrl":
		return name("LeftControl");
		
	case "LeftAlt":
		return name("LeftAlt");
		
	case "LeftClick":
		return name("LeftMouseButton");
		
	case "RightClick":
		return name("RightMouseButton");
		
	case "MiddleClick":
		return name("MiddleMouseButton");
		
	case "ScrollUp":
		return name("MouseScrollUp");
		
	case "ScrollDown":
		return name("MouseScrollDown");
		
	case "one":
		return name("one");
		
	case "two":
		return name("two");
		
	case "three":
		return name("three");
		
	case "four":
		return name("four");
		
	case "five":
		return name("five");
		
	case "six":
		return name("six");
		
	case "seven":
		return name("seven");
		
	case "eight":
		return name("eight");
		
	case "nine":
		return name("nine");
		
	case "zero":
		return name("zero");
		
	default:
		return name(Caps(binding));
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.Controls'
	
	ListOneCommands[0]="GBA_MoveForward";
	ListOneCommands[1]="GBA_Backward";
	ListOneCommands[2]="GBA_StrafeLeft";
	ListOneCommands[3]="GBA_StrafeRight";
	ListOneCommands[4]="GBA_Sprint";
	ListOneCommands[5]="GBA_Duck";
	ListOneCommands[6]="GBA_Use";
	
	ListTwoCommands[0]="GBA_Fire";	
	ListTwoCommands[1]="GBA_FireAbility";	
	ListTwoCommands[2]="GBA_ADS";	
	ListTwoCommands[3]="GBA_Reload";
	ListTwoCommands[4]="GBA_Melee";
	ListTwoCommands[5]="GBA_PrevWeapon";	
	ListTwoCommands[6]="GBA_NextWeapon";	
	ListTwoCommands[7]="GBA_PrevAbility";	
	ListTwoCommands[8]="GBA_NextAbility";
	ListTwoCommands[9]="GBA_ToggleSide";
	ListTwoCommands[10]="GBA_ToggleUnder";
	ListTwoCommands[11]="GBA_ToggleOptics";
	ListTwoCommands[12]="GBA_ToggleBarrel";
	ListTwoCommands[13]="GBA_ToggleMuzzle";
	ListTwoCommands[14]="GBA_ToggleStock";
	
	bCaptureInput=true
}