/*******************************************************************************
	AC_LARobotForearm

	Creation date: 24/03/2014 16:05
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AC_LARobotForearm extends ArmorComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Arm_RF.Meshes.RobotForearmL'
	End Object
	
	Type=ACTLeftArm
}