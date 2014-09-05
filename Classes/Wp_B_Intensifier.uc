/*******************************************************************************
	Wp_B_Intensifier

	Creation date: 03/09/2014 11:30
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Wp_B_Intensifier extends Wp_Barrel;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'PhotonEmitter.Meshes.Intensifier'
	End Object
	
	Begin Object Name=NewStatMod
	End Object
	
	//MuzzleFlashTemplate=ParticleSystem'BasicRifleBarrel.Particles.MuzzleFlashPS'
	//MFLClass=class'Arena.L_RifleMuzzleFlash'
	
	CompatibleTypes[0]=WTHardLightRifle
	//CompatibleTypes[1]=WTHardLightRifle
	
	//CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	//CompatibleSizes[2]=WSLarge

	SightsOffset=(Z=0.5)
	Weight=3
	ComponentName="Intensifier Barrel"
	ComponentDescription=""
}