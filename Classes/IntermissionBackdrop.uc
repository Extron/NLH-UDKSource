/*******************************************************************************
	IntermissionBackdrop

	Creation date: 26/03/2014 16:10
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class IntermissionBackdrop extends StaticMeshActor;

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ArenaUI.Meshes.BackdropPlane'
		DepthPriorityGroup=SDPG_Foreground
	End Object
	
	bStatic=false
}