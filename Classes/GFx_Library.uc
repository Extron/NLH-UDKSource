/*******************************************************************************
	GFx_Library

	Creation date: 30/05/2013 23:57
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_Library extends GFxObject;

struct BaseTypeElement
{
	var array<class<ArenaWeaponBase> > Bases;
	var WeaponType Type;
};

/**
 * A list of valid bases that the player can choose from, sorted by weapon type.
 */
var array<BaseTypeElement> ValidBases;

/**
 * A list of the current valid weapon components that cas be put on the current weapon base.
 */
var array<class<ArenaWeaponComponent> > ValidComponents;

/**
 * The menu that owns the library.
 */
var GFx_WLSubMenu Parent;

/**
 * The scroll list in the library.
 */
var GFxClikWidget ScrollList, BaseDropdownMenu;

/**
 * A reference to the tooltip on the menu.
 */
var GFx_Tooltip Tooltip;

/**
 * The currently selected base name.
 */
var string CurrentBaseName;

/**
 * The current type of the weapon base.
 */
var WeaponType CurrentType;

/**
 * The index of the selected item.
 */
var int SelectedComponent;


function BuildBaseLibrary(ArenaWeaponBase base)
{
	local array<class<ArenaWeaponBase> > bases;
	local array<GFxObject> baseNames;
	local BaseTypeElement element;
	local GFxObject baseItem;
	local int i;
	
	CurrentType = base.Type;
	
	bases = base.default.Subclasses;
	
	SelectedComponent = -1;
	
	for (i = 0; i < 8; i++)
	{
		element.Type = WeaponType(i);
		ValidBases.AddItem(element);
	}
	
	for (i = 0; i < bases.Length; i++)
	{
		ValidBases[bases[i].default.Type].Bases.AddItem(bases[i]);
		
		if (bases[i].default.Type == CurrentType)
		{
			baseItem = CreateObject("Object");
			baseItem.SetString("name", bases[i].default.BaseName);
			
			if (Parent.Viewer.SaveData.WeapData.BoughtBases.Find(bases[i]) > -1)
				baseItem.SetBool("purchased", true);
			else
				baseItem.SetBool("purchased", false);
				
			baseItem.SetInt("cost", bases[i].default.Cost);
			
			baseNames.AddItem(baseItem);
			
			if (bases[i].default.BaseName == base.BaseName)
				SelectedComponent = i;
		}
	}
	
	CurrentBaseName = base.BaseName;
	
	Parent.FillLibrary(baseNames, base.BaseName, "Bases", CurrentType);	
	ScrollList = GFxClikWidget(GetObject("scrollList", class'GFxClikWidget'));
	BaseDropdownMenu = GFxClikWidget(GetObject("baseDropdownList", class'GFxClikWidget'));
	BaseDropdownMenu.AddEventListener('CLIK_change', OnItemClicked);
}

function BuildComponentLibrary(ArenaWeaponBase base, ArenaWeaponComponent component)
{
	local array<class<ArenaWeaponComponent> > components;
	local array<GFxObject> compNames;
	local GFxObject compItem;
	local int i;
	
	components = component.default.Subclasses;
	
	SelectedComponent = -1;
	
	for (i = 0; i < components.Length; i++)
	{
		if (components[i].default.CompatibleTypes.Find(base.Type) > -1 && components[i].default.CompatibleSizes.Find(base.Size) > -1)
		{
			compItem = CreateObject("Object");
			compItem.SetString("name", components[i].default.ComponentName);
			
			if (Parent.Viewer.SaveData.WeapData.BoughtComponents.Find(components[i]) > -1)
				compItem.SetBool("purchased", true);
			else
				compItem.SetBool("purchased", false);
				
			compItem.SetInt("cost", components[i].default.Cost);
			
			ValidComponents.AddItem(components[i]);
			compNames.AddItem(compItem);
			
			if (components[i].default.ComponentName == component.ComponentName)
				SelectedComponent = i;
		}
	}

	Parent.FillLibrary(compNames, component.ComponentName, GetCategory(component));
	
	ScrollList = GFxClikWidget(GetObject("scrollList", class'GFxClikWidget'));
}

function OnItemClicked(GFxClikWidget.EventData ev)
{
	local array<GFxObject> baseNames;
	local GFxObject baseItem;
	local int index, i;
	
	index = BaseDropdownMenu.GetInt("selectedIndex");
	
	for (i = 0; i < ValidBases[index].Bases.Length; i++)
	{
		baseItem = CreateObject("Object");
		baseItem.SetString("name", ValidBases[index].Bases[i].default.BaseName);
		
		if (Parent.Viewer.SaveData.WeapData.BoughtBases.Find(ValidBases[index].Bases[i]) > -1)
				baseItem.SetBool("purchased", true);
			else
				baseItem.SetBool("purchased", false);
				
		baseItem.SetInt("cost", ValidBases[index].Bases[i].default.Cost);
		
		baseNames.AddItem(baseItem);
	}
	
	SelectedComponent = -1;
	CurrentType = WeaponType(index);
	Parent.FillLibrary(baseNames, CurrentBaseName, "Bases", CurrentType);
}

function string GetCategory(ArenaWeaponComponent component)
{
	if (component.IsA('Wp_Stock'))
		return "Stocks";
	else if (component.IsA('Wp_Barrel'))
		return "Barrels";
	else if (component.IsA('Wp_Muzzle'))
		return "Muzzles";
	else if (component.IsA('Wp_Optics'))
		return "Optics";
	else if (component.IsA('Wp_UnderAttachment'))
		return "Under-barrel Attachments";
	else if (component.IsA('Wp_SideAttachment'))
		return "Side-barrel Attachments";
	else
		return "";
}