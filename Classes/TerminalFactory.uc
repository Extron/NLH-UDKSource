/*******************************************************************************
	TerminalFactory

	Creation date: 17/05/2013 21:03
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class TerminalFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Terminal"
	ActorClass=class'Arena.Terminal'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}