/*******************************************************************************
	AC_RARobotForearm

	Creation date: 24/03/2014 16:06
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BPC_RightArmRobotForearm extends BodyPartComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Arm_RF.Meshes.RobotForearmR'
	End Object
	
	Type=BPTRightArm
	ComponentName="Robotic Forearm"
	ComponentDescription="The arm is amputated at the elbow and the forearm is replaced with a robotic prosthesis.  Requires energy to operate, but provides additional stability and increased strength.  However, suseptible to electromagnetic damage."
	EnergyCost=5
	Cost=15;
}