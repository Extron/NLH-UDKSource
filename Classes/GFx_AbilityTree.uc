/*******************************************************************************
	GFx_AbilityTree

	Creation date: 25/09/2013 10:19
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_AbilityTree extends GFx_Menu;

/**
 * The ability tree that this menu is currently displaying.
 */
var class<AbilityTree> AbilityTree;

var LoadoutData Character;

var Gfx_Menu Parent;

var GFx_AbilityTooltip Tooltip;

var AP_Specter Pawn;

delegate OnClose();

function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
			
    Advance(0);
		
	Tooltip = GFx_AbilityTooltip(GetVariableObject("_root.abilityTooltip", class'Arena.GFx_AbilityTooltip'));
	
	Tooltip.SetVisible(false);
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
		ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = LookUp;
	}
	
	BuildAbilityTree();
	SetPoints(Character.Points);
	
	return true;
}

function LookUp(out vector loc, out rotator rot)
{
	rot.Pitch = 16384;
}

function ButtonClicked(string label)
{
	local class<ArenaAbility> ability;
	
	if (label == "Cancel")
	{
		OnClose = GoBack;
	}
	
	ability = FindAbility(label);
	
	if (ability != None)
	{
		if (IsAbilityUnlocked(ability))
		{
			if (Character.EquippedAbilities.Find(ability) == -1)
				Character.EquippedAbilities.AddItem(ability);
			
			OnClose = ReturnToCharacterView;
			
			CloseMenu();
		}
	}
}

function ButtonUp(string label)
{
	Tooltip.SetVisible(false);
}

function ButtonOver(string label)
{
	local class<ArenaAbility> ability;
	
	ability = FindAbility(label);
	
	if (ability != None && Tooltip != None)
	{
		Tooltip.SetAbilityDetails(ability);
		Tooltip.SetVisible(true);
	}
}

function UnlockEquipAbility(string abilityName)
{
	local class<ArenaAbility> ability;
	
	ability = FindAbility(abilityName);
	
	if (ability != None)
	{
		Character.Points -= ability.default.UnlockPoints;
		Character.UnlockedAbilities.AddItem(ability);
		BuildAbilityTree();
		
		if (Character.EquippedAbilities.Find(ability) == -1)
			Character.EquippedAbilities.AddItem(ability);
		
		OnClose = ReturnToCharacterView;
		
		CloseMenu();
	}
}

function UnlockAbility(string abilityName)
{
	local class<ArenaAbility> ability;
	
	ability = FindAbility(abilityName);
	
	if (ability != None)
	{
		Character.Points -= ability.default.UnlockPoints;
		
		Character.UnlockedAbilities.AddItem(ability);
		
		BuildAbilityTree();
	}
}

function CloseAnimCompleted()
{
	OnClose();
}

function BuildAbilityTree()
{
	local array<GFxObject> abilities;
	local GFxObject ability;
	local int i;
	
	for (i = 0; i < AbilityTree.default.Abilities.Length; i++)
	{
		ability = CreateObject("Object");
		
		if (AbilityTree.default.Abilities[i] != None)
		{
			ability.SetString("abilityName", AbilityTree.default.Abilities[i].default.AbilityName);
			ability.SetString("icon", "img://" $ AbilityTree.default.Abilities[i].default.AbilityIcon);
			ability.SetBool("unlocked", IsAbilityUnlocked(AbilityTree.default.Abilities[i]));
			ability.SetInt("unlockPoints", AbilityTree.default.Abilities[i].default.UnlockPoints);
		}
		
		abilities.AddItem(ability);
	}
	
	SetTree(AbilityTree.default.TreeName, abilities);
}

function bool IsAbilityUnlocked(class<ArenaAbility> ability)
{
	return Character.UnlockedAbilities.Find(ability) > -1;
}

function class<ArenaAbility> FindAbility(string abilityName)
{
	local int i;
	
	for (i = 0; i < AbilityTree.default.Abilities.Length; i++)
	{
		if (AbilityTree.default.Abilities[i] != None && AbilityTree.default.Abilities[i].default.AbilityName == abilityName)
			return AbilityTree.default.Abilities[i];
	}
	
	return None;
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function SetTree(string treeName, array<GFxObject> abilities)
{
	ActionScriptVoid("_root.SetTree");
}

function SetPoints(int points)
{
	ActionScriptVoid("_root.SetPoints");
}

function GoBack()
{
	Pawn.SetMenu(Parent);

	Close();
	
	Parent.PlayOpenAnimation();
	GFx_AbilitiesMenu(Parent).Character = Character;
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = GFx_AbilitiesMenu(Parent).LookUp;
}

function ReturnToCharacterView()
{
	Pawn.SetMenu(Parent);
	Close();
	
	GFx_AbilitiesMenu(Parent).Character = Character;
	
	GFx_AbilitiesMenu(Parent).GoBack();
	GFx_CharacterView(GFx_AbilitiesMenu(Parent).Parent).BuildClassInfo();
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = GFx_CharacterView(GFx_AbilitiesMenu(Parent).Parent).LookUp;
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.AbilityTree'
	
	bCaptureInput=true
}