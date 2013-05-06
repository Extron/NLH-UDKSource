/*******************************************************************************
	InterObjFactory

	Creation date: 18/03/2013 19:06
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class InterObjFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Interactable Object"
	ActorClass=class'Arena.InteractiveObject'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}