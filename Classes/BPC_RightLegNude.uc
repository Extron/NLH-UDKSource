/*******************************************************************************
	AC_RLNude

	Creation date: 10/02/2014 13:15
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BPC_RightLegNude extends BodyPartComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Leg_Nude.Meshes.NudeR'
	End Object
	
	Type=BPTRightLeg
	ComponentName="Organic Leg"
}