/*******************************************************************************
	MenuBackdrop

	Creation date: 27/05/2013 23:04
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class MenuBackdrop extends StaticMeshActor;

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ArenaUI.Meshes.BackdropMesh'
		DepthPriorityGroup=SDPG_Foreground
	End Object
	
	bStatic=false
}