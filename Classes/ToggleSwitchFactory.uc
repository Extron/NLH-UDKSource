/*******************************************************************************
	ToggleSwitchFactory

	Creation date: 28/04/2014 20:33
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class ToggleSwitchFactory extends ActorFactoryDynamicSM;

defaultproperties
{
	MenuName="Add Toggle Switch"
	NewActorClass=class'Arena.ToggleSwitch'
	bShowInEditorQuickMenu=true
}