/*******************************************************************************
	GFx_SBBMapList

	Creation date: 27/06/2013 00:01
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_SBBMapList extends GFx_Menu;


/**
 * The list of maps availible for solo bot battles.
 */
var array<ArenaMapInfo> Maps;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The parent menu that this is displaying over.
 */
var GFx_SoloBotBattle Parent;

/**
 * The cursor of the menu.
 */
var GFxObject Cursor;

/**
 * The tri panel prop used in this menu.
 */
var SkeletalMeshComponent TriPanel;

/**
 * The currently selected index in the map list.
 */
var int SelectedIndex;

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
		if (iter.Tag == 'TriPanel')
		{
			TriPanel = iter.SkeletalMeshComponent;
			break;
		}
	}
	
	TriPanel.Owner.SetHidden(false);
	
	CreateMapList();
	
	return true;
}

function FillList(array<string> items, string sel)
{
	ActionScriptVoid("_root.FillList");
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function PlayOpenAnimation()
{
	local AN_BlendByState node;
	
	foreach TriPanel.AllAnimNodes(class'AN_BlendByState', node)
		node.SetState("Open");
		
	PlayTriPanelAnimation('OpenTriPanelAnim');
}


function PlayCloseAnimation()
{
	local AN_BlendByState node;
	
	foreach TriPanel.AllAnimNodes(class'AN_BlendByState', node)
		node.SetState("Closed");
		
	PlayTriPanelAnimation('CloseTriPanelAnim');
}

function CloseAnimCompleted()
{
	Back();
}

simulated function PlayTriPanelAnimation(name sequence)
{
	local AnimNodePlayCustomAnim node;

	node = AnimNodePlayCustomAnim(AnimTree(TriPanel.Animations).Children[0].Anim);

	node.PlayCustomAnim(sequence, 1.0, , , false);
}

function ButtonClicked(string label)
{
	if (label == "Cancel")
	{
		CloseMenu();
		PlayCloseAnimation();
	}
	else if (label == "Accept")
	{
		Parent.CurrentMap = Maps[SelectedIndex];
		CloseMenu();
		PlayCloseAnimation();
	}
}

function Back()
{
	Pawn.SetMenu(Parent);
	TriPanel.Owner.SetHidden(true);
	Close();
}

function CreateMapList()
{
    local int i;
    local array<UDKUIResourceDataProvider> ProviderList;
    local array<string> DisplayList;
	
	Maps.Length = 0;
	class'UDKUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'ArenaMapInfo', ProviderList);
	
	for (i = 0; i < ProviderList.length; i++)
	{
		if (ArenaMapInfo(ProviderList[i]).GameType == "Bot Battle")
		{
			Maps.AddItem(ArenaMapInfo(ProviderList[i]));
			
			if (ArenaMapInfo(ProviderList[i]).MapName == Parent.CurrentMap.MapName)
				SelectedIndex = Maps.Length - 1;
		}
	}
  
    for (i = 0; i < Maps.Length; i++)
    {
		DisplayList.AddItem(Maps[i].DisplayName);
    }
	
	FillList(DisplayList, DisplayList[SelectedIndex]);
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.SBBMapList'
	
	bCaptureMouseInput=true
}