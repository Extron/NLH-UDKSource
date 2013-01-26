/*******************************************************************************
	BasicRifleBarrel

	Creation date: 10/07/2012 21:10
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_B_BasicRifleBarrel extends Wp_Barrel;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'BasicRifleBarrel.Meshes.BasicBarrelMesh'
		FOV=85.0
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVAccuracy]=0.95
		ValueMods[WSVMobility]=1.1
	End Object
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTShotgun
	CompatibleTypes[2]=WTHardLightRifle
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	Weight=3
	ComponentName="Basic Rifle Barrel"
}