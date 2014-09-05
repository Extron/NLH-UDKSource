/*******************************************************************************
	AC_RANude

	Creation date: 10/02/2014 13:04
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BPC_RightArmNude extends BodyPartComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Arm_Nude.Meshes.NudeR'
	End Object
	
	Type=BPTRightArm
	ComponentName="Organic Arm"
	ComponentDescription="A fully organic arm, with no special modifications."
	EnergyCost=0
	Cost=0;
}