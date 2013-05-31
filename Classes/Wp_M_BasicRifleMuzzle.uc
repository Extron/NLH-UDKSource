/*******************************************************************************
	BasicRifleMuzzle

	Creation date: 10/07/2012 21:14
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_M_BasicRifleMuzzle extends Wp_Muzzle;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'BasicRifleMuzzle.Mesh.BasicRifleMuzzleMesh_1P'
		Rotation=(Yaw=-16384)
	End Object
	
	CompatibleTypes[0]=WTRifle
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	Weight=2
	ComponentName="Basic Rifle Muzzle"
}