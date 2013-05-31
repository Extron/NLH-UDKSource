/*******************************************************************************
	GFx_Library

	Creation date: 30/05/2013 23:57
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_Library extends GFxObject;

/**
 * A list of the current valid weapon components that cas be put on the current weapon base.
 */
var array<class<ArenaWeaponComponent> > ValidComponents;

function BuildLibrary(ArenaWeaponBase base, ArenaWeaponComponent component)
{
	local array<class<ArenaWeaponComponent> > components;
	local array<string> compNames;
	local int i;
	
	components = component.default.Subclasses;
	
	`log("Component count" @ components.Length);
	
	for (i = 0; i < components.Length; i++)
	{
		if (components[i].default.CompatibleTypes.Find(base.Type) > -1 && components[i].default.CompatibleSizes.Find(base.Size) > -1)
		{
			ValidComponents.AddItem(components[i]);
			compNames.AddItem(components[i].default.ComponentName);
		}
	}

	FillLibrary(compNames, component.ComponentName);
}

function FillLibrary(array<string> list, string sel)
{
	ActionScriptVoid("FillLibrary");
}