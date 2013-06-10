/******************************************************************************
	Ab_SandstormCloud
	
	Creation date: 09/06/2013 20:44
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_SandstormCloud extends Ab_DustCloudCloud;


defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=ShieldMesh1
		StaticMesh=StaticMesh'ArenaAbilities.Meshes.BubbleShieldMesh'
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=false
		bCastDynamicShadow=false
		CastShadow=false
		Scale=50
	End Object
	Mesh=ShieldMesh1
}
