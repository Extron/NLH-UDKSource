/*******************************************************************************
	InitialWindowFactory

	Creation date: 09/10/2013 10:57
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class InitialWindowFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Initial Window"
	ActorClass=class'Arena.InitialWindow'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}