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
	local GFxObject baseLabel;
	local array<class<ArenaWeaponBase> > bases;
	local array<string> baseNames;
	local BaseTypeElement element;
	local int i;
	
	CurrentType = base.Type;
	
	bases = base.default.Subclasses;
	
	for (i = 0; i < 8; i++)
	{
		element.Type = WeaponType(i);
		ValidBases.AddItem(element);
	}
	
	for (i = 0; i < bases.Length; i++)
	{
		ValidBases[bases[i].default.Type].Bases.AddItem(bases[i]);
		
		if (bases[i].default.Type == CurrentType)
			baseNames.AddItem(bases[i].default.BaseName);
	}
	
	SelectedComponent = baseNames.Find(base.BaseName);
	CurrentBaseName = base.BaseName;
	
	FillLibrary(baseNames, base.BaseName, "Bases", CurrentType);	
	ScrollList = GFxClikWidget(GetObject("scroll_list", class'GFxClikWidget'));
	baseLabel = GetObject("base_label");
	BaseDropdownMenu = GFxClikWidget(baseLabel.GetObject("base_list", class'GFxClikWidget'));
	BaseDropdownMenu.AddEventListener('CLIK_change', OnItemClicked);
}

function BuildComponentLibrary(ArenaWeaponBase base, ArenaWeaponComponent component)
{
	local array<class<ArenaWeaponComponent> > components;
	local array<string> compNames;
	local int i;
	
	components = component.default.Subclasses;
	
	for (i = 0; i < components.Length; i++)
	{
		if (components[i].default.CompatibleTypes.Find(base.Type) > -1 && components[i].default.CompatibleSizes.Find(base.Size) > -1)
		{
			ValidComponents.AddItem(components[i]);
			compNames.AddItem(components[i].default.ComponentName);
		}
	}

	SelectedComponent = compNames.Find(component.ComponentName);
	
	FillLibrary(compNames, component.ComponentName, GetCategory(component));
	
	ScrollList = GFxClikWidget(GetObject("scroll_list", class'GFxClikWidget'));
}

function FillLibrary(array<string> list, string sel, string category, optional int baseSelection = -1)
{
	ActionScriptVoid("FillLibrary");
}

function OnItemClicked(GFxClikWidget.EventData ev)
{
	local array<string> baseNames;
	local int index, i;
	
	index = BaseDropdownMenu.GetInt("selectedIndex");
	
	for (i = 0; i < ValidBases[index].Bases.Length; i++)
	{
		baseNames.AddItem(ValidBases[index].Bases[i].default.BaseName);
	}
	
	SelectedComponent = -1;
	CurrentType = WeaponType(index);
	FillLibrary(baseNames, CurrentBaseName, "Bases", CurrentType);
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