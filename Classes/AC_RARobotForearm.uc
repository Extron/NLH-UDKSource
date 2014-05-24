/*******************************************************************************
	AC_RARobotForearm

	Creation date: 24/03/2014 16:06
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AC_RARobotForearm extends ArmorComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Arm_RF.Meshes.RobotForearmR'
	End Object
	
	Type=ACTRightArm
}