/*******************************************************************************
	BBWaveManagerFactory

	Creation date: 29/12/2012 15:12
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BBWaveManagerFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Bot Battle Wave Manager"
	ActorClass=class'Arena.BBWaveManager'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}