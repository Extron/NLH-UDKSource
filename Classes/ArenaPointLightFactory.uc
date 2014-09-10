/*******************************************************************************
	ArenaPointLightFactory

	Creation date: 09/09/2014 00:30
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class ArenaPointLightFactory extends ActorFactoryLight;

defaultproperties
{
	MenuName="Add Arena Point Light"
	NewActorClass=class'Arena.ArenaPointLight'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}