/*******************************************************************************
	AmbientLightVolumeFactory

	Creation date: 29/04/2014 09:15
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class AmbientLightVolumeFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Ambient Light Volume"
	ActorClass=class'Arena.AmbientLightVolume'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}