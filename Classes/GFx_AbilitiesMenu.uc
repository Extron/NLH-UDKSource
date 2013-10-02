/*******************************************************************************
	GFx_AbilitiesMenu

	Creation date: 23/09/2013 00:15
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_AbilitiesMenu extends GFx_Menu;

/**
 * The class of abilities to display.
 */
var class<PlayerClass> AbilityClass;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The menu that we can from to get to this menu.
 */
var GFx_Menu Parent;

var class<AbilityTree> SelectedTree;

var LoadoutData Character;

delegate OnClose();


function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
			
    Advance(0);
		
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
		ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = LookUp;
	}
	
	BuildAbilities();

	return true;
}

function LookUp(out vector loc, out rotator rot)
{
	rot.Pitch = 16384;
}

function ButtonClicked(string label)
{
	local class<AbilityTree> tree;
	
	tree = FindTree(label);
	
	if (tree != None)
	{
		SelectedTree = tree;
		OnClose = GotoAbilityTreeMenu;
		CloseMenu();
	}
	
	if (label == "Cancel")
	{
		OnClose = GoBack;
		CloseMenu();
	}
}

function BuildAbilities()
{
	local array<GFxObject> abilities;
	local GFxObject abilityTree;
	local int i;

	for (i = 0; i < AbilityClass.default.Trees.Length; i++)
	{
		abilityTree = CreateObject("Object");
		
		abilityTree.SetString("treeName", AbilityClass.default.Trees[i].default.TreeName);
		abilityTree.SetString("icon", "img://" $ AbilityClass.default.Trees[i].default.TreeIcon);
		
		abilities.AddItem(abilityTree);
	}
	
	SetAbilities(abilities);
}

function class<AbilityTree> FindTree(string treeName)
{
	local int i;
	
	for (i = 0; i < AbilityClass.default.Trees.Length; i++)
	{
		if (AbilityClass.default.Trees[i] != None && AbilityClass.default.Trees[i].default.TreeName == treeName)
			return AbilityClass.default.Trees[i];
	}
	
	return None;
}

function SetAbilities(array<GFxObject> abilities)
{
	ActionScriptVoid("_root.SetAbilities");
}

function PlayOpenAnimation()
{
	ActionScriptVoid("_root.OpenMenu");
}

function GotoAbilityTreeMenu()
{
	local GFx_AbilityTree menu;
	
	menu = new class'Arena.GFx_AbilityTree';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);
	menu.AbilityTree = SelectedTree;
	menu.Parent = self;
	menu.Character = Character;
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
		
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);
}

function GoBack()
{
	Pawn.SetMenu(Parent);

	Close();
	
	Parent.PlayOpenAnimation();
	GFx_CharacterView(Parent).Character = Character;
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = GFx_CharacterView(Parent).LookUp;
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function CloseAnimCompleted()
{
	OnClose();
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.AbilitiesMenu'
	
	bCaptureInput=true
}