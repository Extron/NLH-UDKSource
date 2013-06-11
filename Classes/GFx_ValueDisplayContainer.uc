/*******************************************************************************
	GFx_ValueDisplayContainer

	Creation date: 03/06/2013 21:16
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_ValueDisplayContainer extends GFxObject;

function AddValue(string valName, string valValue)
{
	ActionScriptVoid("AddValue");
}

function InsertValue(string valName, string valValue, int index)
{
	ActionScriptVoid("InsertValue");
}

function RemoveValue(string valName)
{
	ActionScriptVoid("RemoveValue");
}

function ChangeValue(int index, string val)
{
	ActionScriptVoid("ChangeValue");
}

function AddDropdown(string valName, array<string> values, int selection)
{
	ActionScriptVoid("AddDropdown");
}

function InsertDropdown(string valName, array<string> values, int selection, int index)
{
	ActionScriptVoid("InsertDropdown");
}

function RemoveDropdown(string valName)
{
	ActionScriptVoid("RemoveDropdown");
}

function ChangeDropdown(int index, array<string> values, int selection)
{
	ActionScriptVoid("ChangeDropdown");
}

function int GetDropdownIndex(string ddName)
{
	return ActionScriptInt("GetDropdownIndex");
}