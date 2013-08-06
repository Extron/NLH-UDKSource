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
 * The scroll list that displays the list of maps.
 */
var GFxClikWidget ScrollList;

/**
 * The currently selected index in the map list.
 */
var int SelectedIndex;


function bool Start(optional bool StartPaused = false)
{
	local GFxObject itemList;
	
	super.Start(StartPaused);
	
	Advance(0);

	Cursor = GetVariableObject("_root.cursor");
	itemList = GetVariableObject("_root.itemList");
	ScrollList = GFxClikWidget(itemList.GetObject("itemList", class'GFxClikWidget'));
	
	ScrollList.AddEventListener('CLIK_itemClick', OnItemClicked);
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	CreateMapList();
	
	return true;
}

function Update(float dt)
{
}

function FillList(array<string> items, string sel)
{
	ActionScriptVoid("_root.FillList");
}

function SetMapViewer(string ttl, string desc, string imgSrc)
{
	ActionScriptVoid("_root.SetMapViewer");
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function SwapMapViewer(string newTitle, string newDesc, string newImgSrc)
{
	ActionScriptVoid("_root.SwapMapViewer");
}

function CloseAnimCompleted()
{
	Back();
}

function ButtonClicked(string label)
{
	if (label == "Cancel")
	{
		CloseMenu();
	}
	else if (label == "Accept")
	{
		Parent.CurrentMap = Maps[SelectedIndex];
		CloseMenu();
	}
}

function OnItemClicked(GFxClikWidget.EventData ev)
{
	SelectedIndex = ev._this.GetInt("index");
	SwapMapViewer(Maps[SelectedIndex].DisplayName, Maps[SelectedIndex].Description, "img://" $ Maps[SelectedIndex].PreviewImageMarkup);
}

function Back()
{
	Pawn.SetMenu(Parent);
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
	
	SetMapViewer(Maps[SelectedIndex].DisplayName, Maps[SelectedIndex].Description, "img://" $ Maps[SelectedIndex].PreviewImageMarkup);
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.SBBMapList'
	
	bCaptureMouseInput=true
	bCaptureInput=true
}