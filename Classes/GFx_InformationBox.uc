/*******************************************************************************
	GFx_InformationBox

	Creation date: 28/06/2014 13:18
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class GFx_InformationBox extends GFxMoviePlayer;

var InformationBoxDisplay Parent;

var GFxObject DataObject;

delegate OnBack();

delegate OnSliderValueChanged(String featureName, string featureCategory, float featureValue);

delegate OnBarycentricSliderValueChanged(string featureName, float x, float y, float z);

delegate OnRadioButtonSelected(string buttonName);

delegate OnColorChanged(string featureName, Color newColor);

delegate OnDropdownSelectionChanged(string featureName, int selection);

delegate OnEquipSlot(string slotName);

delegate OnDetailsButtonPressed(string buttonName);

function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
	
	Advance(0);
	
	DataObject = CreateObject("Object");
	
	return true;
}

function SetTitle(string title)
{
	ActionScriptVoid("_root.SetTitle");
}

function SetSubtitle(string subtitle)
{
	ActionScriptVoid("_root.SetSubtitle");
}

function PopulateInformation(string layout, GFxObject data)
{
	ActionScriptVoid("_root.PopulateInformation");
}

function Highlight()
{
	ActionScriptVoid("_root.Highlight");
}

function DeHighlight()
{
	ActionScriptVoid("_root.DeHighlight");
}

function Activate()
{
	ActionScriptVoid("_root.Activate");
}

function Deactivate()
{
	ActionScriptVoid("_root.Deactivate");
}

function SetCursorLocation(float x, float y, bool mouseDown)
{
	ActionScriptVoid("_root.SetCursorLocation");
}

function ClickMouse()
{
	ActionScriptVoid("_root.ClickMouse");
}

function MouseDown()
{
	ActionScriptVoid("_root.MouseDown");
}

function MouseUp()
{
	ActionScriptVoid("_root.MouseUp");
}

function InfoBoxBack()
{
	OnBack();
}

function SliderValueChanged(string featureName, string featureCategory, float featureValue)
{
	if (OnSliderValueChanged != None) OnSliderValueChanged(featureName, featureCategory, featureValue);
}

function BarycentricSliderValueChanged(string featureName, float x, float y, float z)
{
	if (OnBarycentricSliderValueChanged != None) OnBarycentricSliderValueChanged(featureName, x, y, z);
}

function ColorChanged(string featureName, byte red, byte green, byte blue)
{
	local color newColor;
	
	newColor.r = red;
	newColor.g = green;
	newColor.b = blue;
	
	if (OnColorChanged != None) OnColorChanged(featureName, newColor);
}

function RadioButtonSelected(string buttonName)
{
	if (OnRadioButtonSelected != None) OnRadioButtonSelected(buttonName);
}

function DropdownSelectionChanged(string featureName, int selection)
{
	if (OnDropdownSelectionChanged != None) OnDropdownSelectionChanged(featureName, selection);
}

function EquipSlot(string slotName)
{
	if (OnEquipSlot != None) OnEquipSlot(slotName);
}

function DetailsButtonPressed(string buttonName)
{
	if (OnDetailsButtonPressed != None) OnDetailsButtonPressed(buttonName);
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.InformationBox'
	RenderTextureMode=RTM_AlphaComposite
	bAllowInput=true
	bAllowFocus=true
	bAutoPlay=true
}