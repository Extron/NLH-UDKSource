/*******************************************************************************
	LightFixtureFactory

	Creation date: 28/04/2014 19:24
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class LightFixtureFactory extends ActorFactoryLight;

defaultproperties
{
	MenuName="Add Light Fixture"
	NewActorClass=class'Arena.LightFixture'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}