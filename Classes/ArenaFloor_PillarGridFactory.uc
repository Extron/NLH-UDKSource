/*******************************************************************************
	ArenaFloor_PillarGridFactory

	Creation date: 11/01/2014 18:50
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaFloor_PillarGridFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Pillar Grid"
	ActorClass=class'Arena.ArenaFloor_PillarGrid'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}