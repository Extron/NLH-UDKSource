/*******************************************************************************
	ArenaFloor_PillarTemplate

	Creation date: 29/01/2014 13:17
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This is a template for the actual pillars that will go into the level.
 */
class ArenaFloor_PillarTemplate extends Actor;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=SM
		StaticMesh = StaticMesh'AO_ArenaFloor.Meshes.PillarEdWireframe'
		Scale3D=(X=1,Y=1,Z=1)
		bCastDynamicShadow=false
		CastShadow=false
	End Object
}