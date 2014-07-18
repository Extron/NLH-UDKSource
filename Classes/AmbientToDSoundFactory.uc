/*******************************************************************************
	AmbientToDSoundFactory

	Creation date: 28/05/2014 20:48
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class AmbientToDSoundFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Ambient Time of Day Sound"
	ActorClass=class'Arena.AmbientToDSound'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}