/*******************************************************************************
	GFx_WeapDescription

	Creation date: 30/05/2013 22:03
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_WeapDescription extends GFxObject;

function SetDisplay(ArenaWeaponComponent component)
{
	SetWeightAndCost(component.Weight, component.EnergyCost);
	SetDescription(component.ComponentDescription);
}

function SetDescription(string desc)
{
	ActionScriptVoid("SetDescription");
}

function SetWeightAndCost(float weight, float cost)
{
	ActionScriptVoid("SetWeightAndCost");
}